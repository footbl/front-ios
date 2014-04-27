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

+ (NSManagedObjectContext *)editableManagedObjectContext {
    return FootblBackgroundManagedObjectContext();
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

#pragma mark - Getters/Setters

@synthesize editableManagedObjectContext;

- (NSManagedObjectContext *)editableManagedObjectContext {
    return [[self class] editableManagedObjectContext];
}

#pragma mark - Instance Methods

- (FootblAPI *)API {
    return [[self class] API];
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

- (void)updateWithData:(NSDictionary *)data {
    
}

@end

@implementation NSManagedObjectContext (Addons)

- (void)deleteObjects:(NSSet *)objects {
    [objects enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [self deleteObject:obj];
    }];
}

@end