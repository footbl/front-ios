//
//  FTModel.h
//  Footbl
//
//  Created by Fernando Saragoça on 8/11/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "_FTModel.h"
#import "FTBConstants.h"
#import "FTCoreDataStore.h"
#import "FTOperationManager.h"
#import "NSManagedObjectContext+FTAddons.h"

extern NSString * const kFTRequestParamResourcePathObject;
extern NSString * const kFTResponseParamIdentifier;

typedef void (^FTAPISuccessWithResponseBlock)(id response);

@interface FTModel : _FTModel

+ (NSString *)resourcePathWithObject:(FTModel *)object;
+ (NSString *)resourcePath;
- (NSString *)resourcePath;

+ (void)createWithParameters:(NSDictionary *)parameters success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
+ (void)getWithObject:(FTModel *)object success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
- (void)getWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
- (void)updateWithParameters:(NSMutableDictionary *)parameters success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
- (void)deleteWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;

- (instancetype)editableObject;

+ (NSArray *)enabledProperties NS_REQUIRES_SUPER;
+ (NSArray *)dateProperties;
+ (NSDictionary *)relationshipProperties;
+ (void)loadContent:(NSArray *)content inManagedObjectContext:(NSManagedObjectContext *)context usingCache:(NSSet *)cache enumeratingObjectsWithBlock:(void (^)(id object, NSDictionary *data))objectBlock untouchedObjectsBlock:(void (^)(NSSet *untouchedObjects))untouchedObjectsBlock completionBlock:(void (^)(NSArray *objects))completionBlock;
- (void)updateWithData:(NSDictionary *)data NS_REQUIRES_SUPER;

+ (instancetype)findWithObject:(id)object inContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)findOrCreateWithObject:(id)object inContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)findOrCreateWithObject:(id)object inContext:(NSManagedObjectContext *)managedObjectContext withCache:(NSSet *)cache;

@end
