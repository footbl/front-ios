//
//  FTAuthenticationManager.m
//  Footbl
//
//  Created by Fernando Saragoça on 8/11/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <FXKeychain/FXKeychain.h>
#import "ErrorHandler.h"
#import "FTAuthenticationManager.h"
#import "FTBuildType.h"
#import "FTImageUploader.h"
#import "NSString+Hex.h"
#import "NSString+SHA1.h"
#import "FTBClient.h"
#import "FTBConstants.h"
#import "FTBUser.h"

static NSString * const kUserEmailKey = @"kUserEmailKey";
static NSString * const kUserIdentifierKey = @"kUserIdentifierKey";
static NSString * const kUserPasswordKey = @"kUserPasswordKey";
static NSString * const kUserFbAuthenticatedKey = @"kUserFbAuthenticatedKey";

NSString * FBAuthenticationManagerGeneratePasswordWithId(NSString *userId) {
    return [NSString stringWithFormat:@"%@%@", userId, FTBSignatureKey].sha1;
}

@interface FTAuthenticationManager ()

@end

#pragma mark FTAuthenticationManager

@implementation FTAuthenticationManager

@synthesize user = _user;

#pragma mark - Class Methods

+ (instancetype)sharedManager {
    static FTAuthenticationManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

#pragma mark - Getters/Setters

- (FTAuthenticationType)authenticationType {
    if (self.email.length > 0 && self.password.length > 0) {
        return FTAuthenticationTypeEmailPassword;
    } else if (self.password.length > 0) {
        return FTAuthenticationTypeAnonymous;
    } else if ([FBSession activeSession].accessTokenData.accessToken.length > 0 && [FXKeychain defaultKeychain][kUserFbAuthenticatedKey]) {
        return FTAuthenticationTypeFacebook;
    } else {
        return FTAuthenticationTypeNone;
    }
}

- (BOOL)isAuthenticated {
    return self.authenticationType != FTAuthenticationTypeNone;
}

- (NSString *)email {
    return [FXKeychain defaultKeychain][kUserEmailKey];
}

- (NSString *)password {
    return [FXKeychain defaultKeychain][kUserPasswordKey];
}

- (void)setUser:(FTBUser *)user {
    _user = user;
	
	[FXKeychain defaultKeychain][kUserIdentifierKey] = (user.identifier.length > 0) ? user.identifier : nil;
	[FXKeychain defaultKeychain][kUserPasswordKey] = (user.password.length > 0) ? user.password : nil;
	[FXKeychain defaultKeychain][kUserEmailKey] = (user.email.length > 0) ? user.email : nil;
}

- (FTBUser *)user {
	if (!_user) {
		NSString *identifier = [FXKeychain defaultKeychain][kUserIdentifierKey];
		if (identifier) {
			_user = [[FTBUser alloc] initWithDictionary:@{@"identifier": identifier} error:nil];
			_user.email = [FXKeychain defaultKeychain][kUserEmailKey];
			_user.password = [FXKeychain defaultKeychain][kUserPasswordKey];
		}
	}
	return _user;
}

- (void)setPushNotificationToken:(NSString *)pushNotificationToken {
    _pushNotificationToken = pushNotificationToken;
    
    [self updateUserWithUsername:nil name:nil email:self.email password:self.password fbToken:[FBSession activeSession].accessTokenData.accessToken profileImage:nil about:nil success:nil failure:nil];
}

#pragma mark - Instance Methods

- (id)init {
    self = [super init];
    if (self) {
        [FXKeychain defaultKeychain][(__bridge id)(kSecAttrAccessible)] = (__bridge id)(kSecAttrAccessibleAlways);
    }
    return self;
}

- (void)ensureAuthenticationWithSuccess:(FTBBlockObject)success failure:(FTBBlockError)failure {
    if (self.isAuthenticated) {
        if (success) success(nil);
        return;
    }
    
    if (self.authenticationType == FTAuthenticationTypeFacebook) {
        [self loginWithFacebookToken:[FBSession activeSession].accessTokenData.accessToken success:success failure:failure];
    } else {
        [self loginWithEmail:self.email password:self.password success:success failure:failure];
    }
}

- (void)createUserWithSuccess:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *password = [NSString randomHexStringWithLength:20];
	[[FTBClient client] POST:@"users" parameters:@{@"password" : password} success:^(NSURLSessionDataTask *task, id responseObject) {
		[self loginWithEmail:nil password:password success:^(id response) {
			if (success) success(responseObject);
		} failure:failure];
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
		if (failure) failure(error);
	}];
}

- (void)loginWithFacebookToken:(NSString *)fbToken success:(FTBBlockObject)success failure:(FTBBlockError)failure {
    BOOL shouldSendNotification = (self.authenticationType == FTAuthenticationTypeNone);
	[[FTBClient client].requestSerializer setValue:fbToken forHTTPHeaderField:@"facebook-token"];
	[[FTBClient client] GET:@"users/me/auth" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
		[FXKeychain defaultKeychain][kUserFbAuthenticatedKey] = @YES;
		[[FTBClient client] user:responseObject[@"_id"] success:^(id object) {
			self.user = object;
			[[FTBClient client].requestSerializer setValue:nil forHTTPHeaderField:@"facebook-token"];
			[self registerForRemoteNotifications];
			if (shouldSendNotification) {
				[[NSNotificationCenter defaultCenter] postNotificationName:kFTNotificationAuthenticationChanged object:nil];
			}
			if (success) success(object);
		} failure:^(NSError *error) {
			if (failure) failure(error);
		}];
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
		if (failure) failure(error);
	}];
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password success:(FTBBlockObject)success failure:(FTBBlockError)failure {
    BOOL shouldSendNotification = (self.authenticationType == FTAuthenticationTypeNone);
	NSMutableDictionary *parameters = [NSMutableDictionary new];
	if (email) parameters[@"email"] = email;
	if (password) parameters[@"password"] = password;
	[[FTBClient client] GET:@"users/me/auth" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
		[FXKeychain defaultKeychain][kUserFbAuthenticatedKey] = nil;
		[[FTBClient client] user:responseObject[@"_id"] success:^(id object) {
			self.user = object;
			[self registerForRemoteNotifications];
			if (shouldSendNotification) {
				[[NSNotificationCenter defaultCenter] postNotificationName:kFTNotificationAuthenticationChanged object:nil];
			}
			if (success) success(object);
		} failure:failure];
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
		if (((NSHTTPURLResponse *)task.response).statusCode == 403) {
			if (self.isAuthenticated) {
				[ErrorHandler sharedInstance].shouldShowError = NO;
				[self logout];
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					[ErrorHandler sharedInstance].shouldShowError = YES;
				});
				error = [NSError errorWithDomain:kFTErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"Error: authentication error, need to login again", @"")}];
			} else {
				error = [NSError errorWithDomain:kFTErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"Error: invalid username or password", @"")}];
			}
		}
		if (failure) failure(error);
	}];
}

- (void)registerForRemoteNotifications {
#if TARGET_IPHONE_SIMULATOR
    return;
#endif
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
    }
#else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
#endif
}

- (void)authenticateFacebookWithCompletion:(void (^)(FBSession *session, FBSessionState status, NSError *error))completionBlock {
    if ([FBSession activeSession].isOpen && [FBSession activeSession].accessTokenData.accessToken.length > 0) {
        completionBlock([FBSession activeSession], [FBSession activeSession].state, nil);
        return;
    }
    
    switch (FTGetBuildType()) {
        case FTBuildTypeAppStore: {
            [FBSession openActiveSessionWithReadPermissions:FB_READ_PERMISSIONS allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                if (completionBlock) completionBlock(session, status, error);
            }];
            break;
        }
        default: {
            [FBSession setActiveSession:[[FBSession alloc] initWithPermissions:FB_READ_PERMISSIONS]];
            [[FBSession activeSession] openWithBehavior:FBSessionLoginBehaviorForcingWebView completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                [FBSession setActiveSession:session];
                if (completionBlock) completionBlock(session, status, error);
            }];
            break;
        }
    }
}

- (void)updateUserWithUsername:(NSString *)username name:(NSString *)name email:(NSString *)email password:(NSString *)password fbToken:(NSString *)fbToken profileImage:(UIImage *)profileImage about:(NSString *)about success:(FTBBlockObject)success failure:(FTBBlockError)failure {
    void(^updateAccountBlock)(NSString *picturePath) = ^(NSString *picturePath) {
		NSString *apnsToken = (self.pushNotificationToken.length > 0) ? self.pushNotificationToken : nil;
		[[FTBClient client] updateUser:self.user username:username name:name email:email password:password fbToken:fbToken apnsToken:apnsToken imagePath:picturePath about:about success:^(id object) {
			if (fbToken.length > 0) {
				[FXKeychain defaultKeychain][kUserFbAuthenticatedKey] = @YES;
			}
			if (email.length > 0) {
				self.user.email = email;
			}
			if (password.length > 0) {
				self.user.password = password;
			}
			if (success) success(object);
		} failure:^(NSError *error) {
			if (error.code == 500) {
				error = [NSError errorWithDomain:kFTErrorDomain code:error.code userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Error: email or username already taken", @"")}];
			}
			if (failure) failure(error);
		}];
    };
	
    [FTImageUploader uploadImage:profileImage withSuccess:^(id response) {
        updateAccountBlock(response);
    } failure:^(NSError *error) {
        updateAccountBlock(nil);
    }];
}

- (BOOL)isValidPassword:(NSString *)password {
    return [self.password isEqualToString:password];
}

- (void)logout {
    [ErrorHandler sharedInstance].shouldShowError = NO;
    [[[FTBClient client] operationQueue] cancelAllOperations];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ErrorHandler sharedInstance].shouldShowError = YES;
    });
	
	self.user = nil;
    [FXKeychain defaultKeychain][kUserFbAuthenticatedKey] = nil;
    
    @try {
        [[FBSession activeSession] closeAndClearTokenInformation];
        [FBSession setActiveSession:nil];
    }
    @catch (NSException *exception) {}
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFTNotificationAuthenticationChanged object:nil];
}

@end
