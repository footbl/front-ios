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

#define API_DICTIONARY_KEY [NSString stringWithFormat:@"%s", __FUNCTION__]
#define API_CURRENT_PAGE(key) [FootblModel pagingDictionary][key] ? [[FootblModel pagingDictionary][key] integerValue] : 0
#define API_SET_CURRENT_PAGE(page, key) [FootblModel pagingDictionary][key] = @(page)
#define API_RESULT(key) [FootblModel resultDictionary][key] ? [FootblModel resultDictionary][key] : [NSMutableArray new]
#define API_SET_RESULT(result, key) [FootblModel resultDictionary][key] = result
#define API_RESET_KEY(key) API_SET_RESULT([NSMutableArray new], key); API_SET_CURRENT_PAGE(0, key)
#define API_APPEND_RESULT(result, key) ![FootblModel resultDictionary][key] ? [FootblModel resultDictionary][key] = [NSMutableArray new] : 0; [FootblModel resultDictionary][key] = [[FootblModel resultDictionary][key] arrayByAddingObjectsFromArray:responseObject]
#define API_APPEND_PAGE(key) [FootblModel pagingDictionary][key] = @([[FootblModel pagingDictionary][key] integerValue] + 1)

@interface FootblModel : _FootblModel

@property (strong, nonatomic, readonly) NSManagedObjectContext *editableManagedObjectContext;

+ (FootblAPI *)API;
+ (NSString *)resourcePath;
+ (instancetype)findByIdentifier:(NSString *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)findOrCreateByIdentifier:(NSString *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)findOrCreateByIdentifier:(NSString *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext usingCache:(NSSet *)cache;
+ (NSMutableDictionary *)pagingDictionary;
+ (NSMutableDictionary *)resultDictionary;
+ (NSMutableDictionary *)generateDefaultParameters;
+ (NSMutableDictionary *)generateParametersWithPage:(NSInteger)page;
+ (NSManagedObjectContext *)editableManagedObjectContext;
+ (NSInteger)responseLimit;
+ (void)loadContent:(NSArray *)content inManagedObjectContext:(NSManagedObjectContext *)context usingCache:(NSSet *)cache enumeratingObjectsWithBlock:(void (^)(id object, NSDictionary *contentEntry))objectBlock deletingUntouchedObjectsWithBlock:(void (^)(NSSet *untouchedObjects))deleteBlock;
+ (void)updateWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
+ (void)createWithParameters:(NSDictionary *)parameters success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (FootblAPI *)API;
- (NSString *)resourcePath;
- (instancetype)editableObject;
- (NSMutableDictionary *)generateDefaultParameters;
- (NSMutableDictionary *)generateParametersWithPage:(NSInteger)page;
- (NSInteger)responseLimit;
- (void)updateWithData:(NSDictionary *)data NS_REQUIRES_SUPER;
- (void)updateWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;

@end

@interface NSManagedObjectContext (Addons)

- (void)deleteObjects:(NSSet *)objects;

@end