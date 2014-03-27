//
//  FootblAPI.h
//  Footbl
//
//  Created by Fernando Saragoça on 3/25/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

typedef void (^FootblAPISuccessBlock)();
typedef void (^FootblAPIFailureBlock)(NSError *error);

extern NSManagedObjectContext * FootblBackgroundManagedObjectContext();
extern NSManagedObjectContext * FootblManagedObjectContext();
extern void requestSucceedWithBlock(id responseObject, FootblAPISuccessBlock success);
extern void requestFailedWithBlock(AFHTTPRequestOperation *operation, NSDictionary *parameters, NSError *error, FootblAPIFailureBlock failure);
extern void SaveManagedObjectContext(NSManagedObjectContext *managedObjectContext);

extern NSString * const kAPIIdentifierKey;

@interface FootblAPI : AFHTTPRequestOperationManager

@property (copy, nonatomic, readonly) NSString *userIdentifier;
@property (copy, nonatomic, readonly) NSString *userEmail;
@property (copy, nonatomic, readonly) NSString *userPassword;

+ (instancetype)sharedAPI;

- (NSMutableDictionary *)generateDefaultParameters;
// Config
- (void)updateConfigWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
// Users
- (void)createAccountWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)ensureAuthenticationWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (BOOL)isAuthenticated;
- (void)loginWithEmail:(NSString *)email password:(NSString *)password success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)loginWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)logout;
- (void)updateAccountWithUsername:(NSString *)username email:(NSString *)email password:(NSString *)password success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;

@end
