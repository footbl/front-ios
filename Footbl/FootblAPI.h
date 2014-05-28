//
//  FootblAPI.h
//  Footbl
//
//  Created by Fernando Saragoça on 3/25/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import <FacebookSDK/FacebookSDK.h>

typedef void (^FootblAPISuccessBlock)();
typedef void (^FootblAPISuccessWithResponseBlock)(NSArray *response);
typedef void (^FootblAPIFailureBlock)(NSError *error);

extern NSManagedObjectContext * FootblBackgroundManagedObjectContext();
extern NSManagedObjectContext * FootblManagedObjectContext();
extern NSString * generateFacebookPasswordWithUserId(NSString *userId);
void requestSucceedWithBlock(AFHTTPRequestOperation *operation, NSDictionary *parameters, FootblAPISuccessBlock success);
extern void requestFailedWithBlock(AFHTTPRequestOperation *operation, NSDictionary *parameters, NSError *error, FootblAPIFailureBlock failure);
extern void SaveManagedObjectContext(NSManagedObjectContext *managedObjectContext);

extern NSString * const FootblAPIErrorDomain;
extern NSString * const kAPIIdentifierKey;
extern NSString * const kFootblAPINotificationAuthenticationChanged;

typedef NS_ENUM(NSInteger, FootblAuthenticationType) {
    FootblAuthenticationTypeNone = 0,
    FootblAuthenticationTypeAnonymous = 1,
    FootblAuthenticationTypeFacebook = 2,
    FootblAuthenticationTypeEmailPassword = 3
};

@class FBSession;
@class User;

@interface FootblAPI : AFHTTPRequestOperationManager

@property (strong, nonatomic) User *currentUser;
@property (copy, nonatomic, readonly) NSString *userIdentifier;
@property (copy, nonatomic, readonly) NSString *userEmail;
@property (copy, nonatomic, readonly) NSString *userPassword;
@property (copy, nonatomic) NSString *pushNotificationToken;
@property (assign, nonatomic, readonly) NSInteger responseLimit;

+ (instancetype)sharedAPI;
+ (void)performOperationWithoutGrouping:(void (^)())block;

- (NSMutableDictionary *)generateDefaultParameters;
- (FootblAuthenticationType)authenticationType;
- (void)groupOperationsWithKey:(id)key block:(dispatch_block_t)block success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)finishGroupedOperationsWithKey:(id)key error:(NSError *)error;
// Config
- (void)updateConfigWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
// Users
- (void)createAccountWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)ensureAuthenticationWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (BOOL)isAuthenticated;
- (void)loginWithEmail:(NSString *)email password:(NSString *)password success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)loginWithFacebookToken:(NSString *)facebookToken success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)authenticateFacebookWithCompletion:(void (^)(FBSession *session, FBSessionState status, NSError *error))completionBlock;
- (void)logout;
- (void)updateAccountWithUsername:(NSString *)username name:(NSString *)name email:(NSString *)email password:(NSString *)password fbToken:(NSString *)fbToken profileImage:(UIImage *)profileImage about:(NSString *)about success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)uploadImage:(UIImage *)image withCompletionBlock:(void (^)(NSString *response, NSError *error))completionBlock;

@end
