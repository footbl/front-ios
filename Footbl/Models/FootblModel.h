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

@property (strong, nonatomic, readonly) NSManagedObjectContext *editableManagedObjectContext;

+ (FootblAPI *)API;
+ (instancetype)findByIdentifier:(NSString *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)findOrCreateByIdentifier:(NSString *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)findOrCreateByIdentifier:(NSString *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext usingCache:(NSSet *)cache;
+ (NSMutableDictionary *)generateDefaultParameters;
+ (NSManagedObjectContext *)editableManagedObjectContext;
+ (void)loadContent:(NSArray *)content inManagedObjectContext:(NSManagedObjectContext *)context usingCache:(NSSet *)cache enumeratingObjectsWithBlock:(void (^)(id object, NSDictionary *contentEntry))objectBlock deletingUntouchedObjectsWithBlock:(void (^)(NSSet *untouchedObjects))deleteBlock;
- (FootblAPI *)API;
- (instancetype)editableObject;
- (NSMutableDictionary *)generateDefaultParameters;
- (void)updateWithData:(NSDictionary *)data;

@end

@interface NSManagedObjectContext (Addons)

- (void)deleteObjects:(NSSet *)objects;

@end