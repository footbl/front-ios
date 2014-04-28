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
+ (NSString *)resourcePath;
+ (instancetype)findByIdentifier:(NSString *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)findOrCreateByIdentifier:(NSString *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)findOrCreateByIdentifier:(NSString *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext usingCache:(NSSet *)cache;
+ (NSMutableDictionary *)generateDefaultParameters;
+ (NSManagedObjectContext *)editableManagedObjectContext;
+ (void)loadContent:(NSArray *)content inManagedObjectContext:(NSManagedObjectContext *)context usingCache:(NSSet *)cache enumeratingObjectsWithBlock:(void (^)(id object, NSDictionary *contentEntry))objectBlock deletingUntouchedObjectsWithBlock:(void (^)(NSSet *untouchedObjects))deleteBlock;
+ (void)updateWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
+ (void)createWithParameters:(NSDictionary *)parameters success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (FootblAPI *)API;
- (NSString *)resourcePath;
- (instancetype)editableObject;
- (NSMutableDictionary *)generateDefaultParameters;
- (void)updateWithData:(NSDictionary *)data NS_REQUIRES_SUPER;
- (void)updateWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;

@end

@interface NSManagedObjectContext (Addons)

- (void)deleteObjects:(NSSet *)objects;

@end