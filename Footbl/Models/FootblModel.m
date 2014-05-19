//
//  FootblModel.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/26/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "FootblModel.h"

@interface FootblModel ()

@end

#pragma mark FootblModel

@implementation FootblModel

#pragma mark - Class Methods

+ (FootblAPI *)API {
    return [FootblAPI sharedAPI];
}

+ (NSString *)resourcePath {
    return @"";
}

+ (instancetype)findByIdentifier:(NSString *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext usingCache:(NSSet *)cache createIfNil:(BOOL)createIfNil {
    if ([identifier isKindOfClass:[NSDictionary class]]) {
        identifier = ((NSDictionary *)identifier)[kAPIIdentifierKey];
    }
    
    FootblModel *object = nil;
    if (cache) {
        object = [cache filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"rid = %@", identifier]].anyObject;
    } else {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"rid = %@", identifier];
        fetchRequest.fetchLimit = 1;
        NSError *error = nil;
        NSArray *fetchResult = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (error) {
            SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        object = fetchResult.firstObject;
    }
    
    if (!createIfNil || object) {
        return object;
    }
    
    object = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:managedObjectContext];
    object.rid = identifier;
    return object;
}

+ (instancetype)findByIdentifier:(NSString *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    return [self findByIdentifier:identifier inManagedObjectContext:managedObjectContext usingCache:nil createIfNil:NO];
}

+ (instancetype)findOrCreateByIdentifier:(NSString *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    return [self findByIdentifier:identifier inManagedObjectContext:managedObjectContext usingCache:nil createIfNil:YES];
}

+ (instancetype)findOrCreateByIdentifier:(NSString *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext usingCache:(NSSet *)cache {
    return [self findByIdentifier:identifier inManagedObjectContext:managedObjectContext usingCache:cache createIfNil:YES];
}

+ (NSMutableDictionary *)generateDefaultParameters {
    return [[self API] generateDefaultParameters];
}

+ (NSMutableDictionary *)generateParametersWithPage:(NSInteger)page {
    NSMutableDictionary *parameters = [self generateDefaultParameters];
    parameters[@"page"] = @(page);
    return parameters;
}

+ (NSManagedObjectContext *)editableManagedObjectContext {
    return FootblBackgroundManagedObjectContext();
}

+ (NSMutableDictionary *)pagingDictionary {
    static NSMutableDictionary *pagingDictionary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pagingDictionary = [NSMutableDictionary new];
    });
    return pagingDictionary;
}

+ (NSMutableDictionary *)resultDictionary {
    static NSMutableDictionary *resultDictionary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        resultDictionary = [NSMutableDictionary new];
    });
    return resultDictionary;
}

+ (NSInteger)responseLimit {
    return [FootblAPI sharedAPI].responseLimit;
}

+ (void)loadContent:(NSArray *)content inManagedObjectContext:(NSManagedObjectContext *)context usingCache:(NSSet *)specifiedCache enumeratingObjectsWithBlock:(void (^)(id object, NSDictionary *contentEntry))objectBlock deletingUntouchedObjectsWithBlock:(void (^)(NSSet *untouchedObjects))deleteBlock {
    [self.editableManagedObjectContext performBlock:^{
        NSSet *cache = specifiedCache;
        if (!cache) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
            fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"rid" ascending:YES]];
            
            NSError *error = nil;
            NSArray *fetchResult = [self.editableManagedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (error) {
                SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            cache = [NSSet setWithArray:fetchResult];
        }
        
        NSMutableSet *untouchedObjects = [cache mutableCopy];
        for (NSDictionary *entry in content) {
            FootblModel *object = [[self class] findOrCreateByIdentifier:entry[kAPIIdentifierKey] inManagedObjectContext:self.editableManagedObjectContext usingCache:cache];
            [object updateWithData:entry];
            if (objectBlock) objectBlock(object, entry);
            [untouchedObjects removeObject:object];
        }
        
        if (deleteBlock) deleteBlock(untouchedObjects);
        
        SaveManagedObjectContext(context);
    }];
}

+ (void)updateWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    NSString *key = [NSString stringWithFormat:@"%@%@", NSStringFromClass([self class]), API_DICTIONARY_KEY];
    [[self API] groupOperationsWithKey:key block:^{
        [[self API] ensureAuthenticationWithSuccess:^{
            NSMutableDictionary *parameters = [self generateParametersWithPage:API_CURRENT_PAGE(key)];
            [[self API] GET:[[self class] resourcePath] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                API_APPEND_RESULT(responseObject, key);
                if ([responseObject count] == [self responseLimit]) {
                    API_APPEND_PAGE(key);
                    [FootblAPI performOperationWithoutGrouping:^{
                       [self updateWithSuccess:success failure:failure];
                    }];
                } else {
                    [self loadContent:API_RESULT(key) inManagedObjectContext:self.editableManagedObjectContext usingCache:nil enumeratingObjectsWithBlock:nil deletingUntouchedObjectsWithBlock:^(NSSet *untouchedObjects) {
                        [[self editableManagedObjectContext] deleteObjects:untouchedObjects];
                        requestSucceedWithBlock(operation, parameters, success);
                    }];
                    requestSucceedWithBlock(operation, parameters, nil);
                    if (success) success();
                    [[self API] finishGroupedOperationsWithKey:key error:nil];
                    API_RESET_KEY(key);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                requestFailedWithBlock(operation, parameters, error, failure);
                [[self API] finishGroupedOperationsWithKey:key error:error];
                API_RESET_KEY(key);
            }];
        } failure:^(NSError *error) {
            [[self API] finishGroupedOperationsWithKey:key error:error];
            if (failure) failure(error);
        }];
    } success:success failure:failure];
}

+ (void)createWithParameters:(NSDictionary *)parameters success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *mutableParameters = [parameters mutableCopy];
        [mutableParameters addEntriesFromDictionary:[self generateDefaultParameters]];
        [[self API] POST:[[self class] resourcePath] parameters:mutableParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.editableManagedObjectContext performBlock:^{
                FootblModel *object = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:self.editableManagedObjectContext];
                object.rid = responseObject[kAPIIdentifierKey];
                [object updateWithData:responseObject];
                SaveManagedObjectContext(self.editableManagedObjectContext);
                requestSucceedWithBlock(operation, mutableParameters, success);
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, mutableParameters, error, failure);
        }];
    } failure:failure];
}

#pragma mark - Getters/Setters

@synthesize editableManagedObjectContext;

- (NSManagedObjectContext *)editableManagedObjectContext {
    return [[self class] editableManagedObjectContext];
}

#pragma mark - Instance Methods

- (FootblAPI *)API {
    return [[self class] API];
}

- (NSString *)resourcePath {
    return [[self class] resourcePath];
}

- (instancetype)editableObject {
    if (self.managedObjectContext == self.editableManagedObjectContext) {
        return self;
    }
    return (id)[self.editableManagedObjectContext objectWithID:self.objectID];
}

- (NSMutableDictionary *)generateDefaultParameters {
    return [[self class] generateDefaultParameters];
}

- (NSMutableDictionary *)generateParametersWithPage:(NSInteger)page {
    return [[self class] generateParametersWithPage:page];
}

- (NSInteger)responseLimit {
    return [[self class] responseLimit];
}

- (void)updateWithData:(NSDictionary *)data {
    self.rid = data[kAPIIdentifierKey];
}

- (void)updateWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [[self API] GET:[self.resourcePath stringByAppendingPathComponent:self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.editableManagedObjectContext performBlock:^{
                [self.editableObject updateWithData:responseObject];
                SaveManagedObjectContext(self.editableManagedObjectContext);
                requestSucceedWithBlock(operation, parameters, success);
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

@end

@implementation NSManagedObjectContext (Addons)

- (void)deleteObjects:(NSSet *)objects {
    [objects enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [self deleteObject:obj];
    }];
}

@end