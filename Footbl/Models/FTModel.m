//
//  FTModel.m
//  Footbl
//
//  Created by Fernando Saragoça on 8/11/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SPHipster/SPLog.h>
#import <TransformerKit/TransformerKit.h>
#import "AppDelegate.h"
#import "FTModel.h"

#pragma mark FTModel

NSString * const kFTRequestParamResourcePathObject = @"FTRequestParamResourcePathObject";
NSString * const kFTResponseParamIdentifier = @"slug";
NSString * const kFTErrorDomain = @"FootblAPIErrorDomain";

@implementation FTModel

#pragma mark - Resource Path

+ (NSString *)resourcePathWithObject:(FTModel *)object {
    if (!object) {
        return [self resourcePath];
    }
    
    return [object.resourcePath stringByAppendingPathComponent:[self resourcePath]];
}

+ (NSString *)resourcePath {
    return @"";
}

- (NSString *)resourcePath {
    return [[self.class resourcePath] stringByAppendingPathComponent:self.rid];
}

#pragma mark - CRUD

+ (void)getWithObject:(FTModel *)object success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    NSString *path = [self resourcePathWithObject:object];
    [[FTOperationManager sharedManager] GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[self class] loadContent:responseObject inManagedObjectContext:[[self class] editableManagedObjectContext] usingCache:nil enumeratingObjectsWithBlock:nil untouchedObjectsBlock:^(NSSet *untouchedObjects) {
            [[self editableManagedObjectContext] deleteObjects:untouchedObjects];
        } completionBlock:success];
    } failure:failure];
}

+ (void)createWithParameters:(NSDictionary *)parameters success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    NSString *path = [self resourcePath];
    NSMutableDictionary *mutableParameters = [parameters mutableCopy];
    if (mutableParameters[kFTRequestParamResourcePathObject]) {
        path = [self resourcePathWithObject:parameters[kFTRequestParamResourcePathObject]];
        [mutableParameters removeObjectForKey:kFTRequestParamResourcePathObject];
    }
    [[FTOperationManager sharedManager] POST:path parameters:mutableParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[[self class] editableManagedObjectContext] performBlock:^{
            FTModel *object = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:[self editableManagedObjectContext]];
            [object updateWithData:responseObject];
            [[self editableManagedObjectContext] performSave];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) success(object.editableObject);
            });
        }];
    } failure:failure];
}

- (void)getWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[FTOperationManager sharedManager] GET:self.resourcePath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[[self class] editableManagedObjectContext] performBlock:^{
            [self.editableObject updateWithData:responseObject];
            [[[self class] editableManagedObjectContext] performSave];
            dispatch_async(dispatch_get_main_queue(), ^{
               if (success) success(self.editableObject);
            });
        }];
    } failure:failure];
}

- (void)updateWithParameters:(NSMutableDictionary *)parameters success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[FTOperationManager sharedManager] PUT:self.resourcePath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[[self class] editableManagedObjectContext] performBlock:^{
            [self.editableObject updateWithData:responseObject];
            [[[self class] editableManagedObjectContext] performSave];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) success(self.editableObject);
            });
        }];
    } failure:failure];
}

- (void)deleteWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[FTOperationManager sharedManager] DELETE:self.resourcePath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[[self class] editableManagedObjectContext] performBlock:^{
            [[[self class] editableManagedObjectContext] deleteObject:self.editableObject];
            [[[self class] editableManagedObjectContext] performSave];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) success(self.editableObject);
            });
        }];
    } failure:failure];
}

#pragma mark - Updating data

+ (NSArray *)ignoredProperties {
    return @[kFTResponseParamIdentifier];
}

+ (NSArray *)dateProperties {
    return @[@"date", @"createdAt", @"updatedAt"];
}

+ (NSDictionary *)relationshipProperties {
    return @{};
}

- (void)updateWithData:(NSDictionary *)data {
    if (data[kFTResponseParamIdentifier]) {
        self.rid = data[kFTResponseParamIdentifier];
        self.slug = data[kFTResponseParamIdentifier];
    }
    
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([[[self class] ignoredProperties] containsObject:key]) {
            return;
        }
        
        if ([[self class] relationshipProperties][key] || ![self respondsToSelector:NSSelectorFromString(key)]) {
            if ([obj isKindOfClass:[NSDictionary class]] && !obj[kFTResponseParamIdentifier]) {
                [self updateWithData:obj];
            }
            return;
        }
        
        if ([[[self class] dateProperties] containsObject:key]) {
            NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName];
            [self setValue:[transformer reverseTransformedValue:obj] forKey:key];
            return;
        }
        
        if ([obj isKindOfClass:[NSNull class]]) {
            [self setValue:nil forKey:key];
            return;
        }
        
        [self setValue:obj forKey:key];
    }];
}

+ (void)loadContent:(NSArray *)content inManagedObjectContext:(NSManagedObjectContext *)context usingCache:(NSSet *)cache enumeratingObjectsWithBlock:(void (^)(id object, NSDictionary *data))objectBlock untouchedObjectsBlock:(void (^)(NSSet *untouchedObjects))untouchedObjectsBlock completionBlock:(void (^)(NSArray *objects))completionBlock {
    [context performBlock:^{
        NSSet *localCache = cache;
        if (!localCache) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
            fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"rid" ascending:YES]];
            
            NSError *error = nil;
            NSArray *fetchResult = [context executeFetchRequest:fetchRequest error:&error];
            if (error) {
                SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            localCache = [NSSet setWithArray:fetchResult];
        }
        
        NSMutableSet *untouchedObjects = [localCache mutableCopy];
        NSMutableArray *objects = [NSMutableArray new];
        for (NSDictionary *entry in content) {
            if ([entry isKindOfClass:[NSNull class]]) {
                continue;
            }
            FTModel *object = [[self class] findOrCreateWithObject:entry inContext:context withCache:localCache];
            if (objectBlock) objectBlock(object, entry);
            [untouchedObjects removeObject:object];
            [objects addObject:object];
        }
        
        if (untouchedObjectsBlock) untouchedObjectsBlock(untouchedObjects);
        
        [context performSave];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) completionBlock(objects);
        });
    }];
}

#pragma mark - NSManagedObjectContext

+ (NSManagedObjectContext *)managedObjectContext {
    return [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
}

+ (NSManagedObjectContext *)editableManagedObjectContext {
    return [(AppDelegate *)[UIApplication sharedApplication].delegate backgroundManagedObjectContext];
}

- (instancetype)editableObject {
    if (self.managedObjectContext == [[self class] editableManagedObjectContext]) {
        return self;
    }
    
    return (FTModel *)[[[self class] editableManagedObjectContext] objectWithID:self.objectID];
}

#pragma mark - Find or Create

+ (instancetype)findWithObject:(id)object inContext:(NSManagedObjectContext *)managedObjectContext createIfNil:(BOOL)createIfNil {
    NSString *rid = nil;
    if ([object isKindOfClass:[NSDictionary class]]) {
        rid = object[kFTResponseParamIdentifier];
    } else if ([object isKindOfClass:[NSString class]]) {
        rid = object;
    } else {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"rid = %@", rid];
    fetchRequest.fetchLimit = 1;
    NSError *error = nil;
    NSArray *fetchResult = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    FTModel *result = fetchResult.firstObject;
    if ([object isKindOfClass:[NSDictionary class]]) {
        [result updateWithData:object];
    }
    
    if (!createIfNil || result) {
        return result;
    }
    
    result = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:managedObjectContext];
    result.rid = rid;
    if ([object isKindOfClass:[NSDictionary class]]) {
        [result updateWithData:object];
    }
    return result;
}

+ (instancetype)findWithObject:(id)object inContext:(NSManagedObjectContext *)managedObjectContext {
    return [self findWithObject:object inContext:managedObjectContext createIfNil:NO];
}

+ (instancetype)findOrCreateWithObject:(id)object inContext:(NSManagedObjectContext *)managedObjectContext {
    return [self findWithObject:object inContext:managedObjectContext createIfNil:YES];
}

+ (instancetype)findOrCreateWithObject:(id)object inContext:(NSManagedObjectContext *)managedObjectContext withCache:(NSSet *)cache {
    NSString *rid = nil;
    if ([object isKindOfClass:[NSDictionary class]]) {
        rid = object[kFTResponseParamIdentifier];
    } else if ([object isKindOfClass:[NSString class]]) {
        rid = object;
    } else {
        return nil;
    }
    
    FTModel *result = [cache filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"rid = %@", rid]].anyObject;
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:managedObjectContext];
        result.rid = rid;
    }
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        [result updateWithData:object];
    }
    
    return result;
}

@end
