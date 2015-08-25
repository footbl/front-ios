//
//  FTAuthenticationManager.h
//  Footbl
//
//  Created by Fernando Saragoça on 8/11/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <Foundation/Foundation.h>
#import "FTBConstants.h"

@class User;
@class FTBUser;

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
@property (strong, nonatomic) FTBUser *user;

+ (instancetype)sharedManager;
- (void)createUserWithSuccess:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)ensureAuthenticationWithSuccess:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)loginWithFacebookToken:(NSString *)fbToken success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)loginWithEmail:(NSString *)email password:(NSString *)password success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)authenticateFacebookWithCompletion:(void (^)(FBSession *session, FBSessionState status, NSError *error))completionBlock;
- (void)updateUserWithUsername:(NSString *)username name:(NSString *)name email:(NSString *)email password:(NSString *)password fbToken:(NSString *)fbToken profileImage:(UIImage *)profileImage about:(NSString *)about success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (BOOL)isValidPassword:(NSString *)password;
- (void)logout;

@end
