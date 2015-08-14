//
//  FTAuthenticationManager.h
//  Footbl
//
//  Created by Fernando Saragoça on 8/11/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <Foundation/Foundation.h>
#import "FTOperationManager.h"

@class User;

typedef NS_ENUM(NSInteger, FTAuthenticationType) {
    FTAuthenticationTypeNone = 0,
    FTAuthenticationTypeAnonymous = 1,
    FTAuthenticationTypeFacebook = 2,
    FTAuthenticationTypeEmailPassword = 3
};

extern NSString * FBAuthenticationManagerGeneratePasswordWithId(NSString *userId);

@interface FTAuthenticationManager : NSObject

@property (copy, nonatomic, readonly) NSString *token;
@property (copy, nonatomic) NSString *pushNotificationToken;
@property (assign, nonatomic, readonly, getter = isAuthenticated) BOOL authenticated;
@property (assign, nonatomic, readonly, getter = isTokenValid) BOOL tokenValid;
@property (assign, nonatomic, readonly) FTAuthenticationType authenticationType;

+ (instancetype)sharedManager;
- (void)createUserWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
- (void)ensureAuthenticationWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
- (void)loginWithFacebookToken:(NSString *)fbToken success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
- (void)loginWithEmail:(NSString *)email password:(NSString *)password success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
- (void)authenticateFacebookWithCompletion:(void (^)(FBSession *session, FBSessionState status, NSError *error))completionBlock;
- (void)updateUserWithUsername:(NSString *)username name:(NSString *)name email:(NSString *)email password:(NSString *)password fbToken:(NSString *)fbToken profileImage:(UIImage *)profileImage about:(NSString *)about success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
- (BOOL)isValidPassword:(NSString *)password;
- (void)logout;

@end
