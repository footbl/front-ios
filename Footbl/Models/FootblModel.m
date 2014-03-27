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

+ (instancetype)findByIdentifier:(NSString *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"rid = %@", identifier];
    fetchRequest.fetchLimit = 1;
    
    NSError *error = nil;
    NSArray *fetchResult = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return fetchResult.firstObject;
}

+ (instancetype)findOrCreateByIdentifier:(NSString *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    FootblModel *object = [self findByIdentifier:identifier inManagedObjectContext:managedObjectContext];
    if (object) {
        return object;
    }
    
    object = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:managedObjectContext];
    object.rid = identifier;
    return object;
}

+ (instancetype)findOrCreateByIdentifier:(NSString *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext usingCache:(NSSet *)cache {
    FootblModel *object = [cache filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"rid = %@", identifier]].anyObject;
    if (object) {
        return object;
    }
    
    object = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:managedObjectContext];
    object.rid = identifier;
    return object;
}

+ (NSMutableDictionary *)generateDefaultParameters {
    return [[self API] generateDefaultParameters];
}

+ (void)loadContent:(NSArray *)content inManagedObjectContext:(NSManagedObjectContext *)context usingCache:(NSSet *)cache enumeratingObjectsWithBlock:(void (^)(id object, NSDictionary *contentEntry))objectBlock deletingUntouchedObjectsWithBlock:(void (^)(NSSet *untouchedObjects))deleteBlock {
    if (!cache) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
//        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"rid IN %@", [content valueForKeyPath:kAPIIdentifierKey]];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"rid" ascending:YES]];
        
        NSError *error = nil;
        NSArray *fetchResult = [FootblBackgroundManagedObjectContext() executeFetchRequest:fetchRequest error:&error];
        cache = [NSSet setWithArray:fetchResult];
    }
    
    NSMutableSet *untouchedObjects = [cache mutableCopy];
    for (NSDictionary *entry in content) {
        FootblModel *object = [[self class] findOrCreateByIdentifier:[entry objectForKey:kAPIIdentifierKey] inManagedObjectContext:FootblBackgroundManagedObjectContext() usingCache:cache];
        [object updateWithData:entry];
        if (objectBlock) objectBlock(object, entry);
        [untouchedObjects removeObject:object];
    }
    
    if (deleteBlock) deleteBlock(untouchedObjects);
    
    SaveManagedObjectContext(context);
}

#pragma mark - Instance Methods

- (FootblAPI *)API {
    return [[self class] API];
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