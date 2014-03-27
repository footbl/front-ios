//
//  FootblModel.h
//  Footbl
//
//  Created by Fernando Saragoça on 3/26/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SPHipster/SPLog.h>
#import "_FootblModel.h"
#import "FootblAPI.h"

@interface FootblModel : _FootblModel

+ (FootblAPI *)API;
+ (instancetype)findByIdentifier:(NSString *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)findOrCreateByIdentifier:(NSString *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)findOrCreateByIdentifier:(NSString *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext usingCache:(NSSet *)cache;
+ (NSMutableDictionary *)generateDefaultParameters;
- (FootblAPI *)API;
- (NSMutableDictionary *)generateDefaultParameters;
+ (void)loadContent:(NSArray *)content inManagedObjectContext:(NSManagedObjectContext *)context usingCache:(NSSet *)cache enumeratingObjectsWithBlock:(void (^)(id object, NSDictionary *contentEntry))objectBlock deletingUntouchedObjectsWithBlock:(void (^)(NSSet *untouchedObjects))deleteBlock;
- (void)updateWithData:(NSDictionary *)data;

@end

@interface NSManagedObjectContext (Addons)

- (void)deleteObjects:(NSSet *)objects;

@end