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

@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *password;
@property (strong, nonatomic) NSDate *tokenExpirationDate;

@end

#pragma mark FTAuthenticationManager

@implementation FTAuthenticationManager

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

@synthesize email = _email;
@synthesize password = _password;
@synthesize user = _user;

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

- (BOOL)isTokenValid {
    return (self.token.length > 0 && self.tokenExpirationDate && [[NSDate date] timeIntervalSinceDate:self.tokenExpirationDate] < 0);
}

- (NSString *)email {
    return [FXKeychain defaultKeychain][kUserEmailKey];
}

- (NSString *)password {
    return [FXKeychain defaultKeychain][kUserPasswordKey];
}

- (void)setEmail:(NSString *)email {
    _email = email;
    [FXKeychain defaultKeychain][kUserEmailKey] = email;
}

- (void)setPassword:(NSString *)password {
    _password = password;
    [FXKeychain defaultKeychain][kUserPasswordKey] = password;
}

- (FTBUser *)user {
	if (!_user) {
		NSString *identifier = [FXKeychain defaultKeychain][kUserIdentifierKey];
		if (identifier) {
			_user = [[FTBUser alloc] initWithDictionary:@{@"identifier": identifier} error:nil];
		}
	}
	return _user;
}

- (void)setUser:(FTBUser *)user {
	_user = user;
	
	[FXKeychain defaultKeychain][kUserIdentifierKey] = (user.identifier.length > 0) ? user.identifier : nil;
}

- (void)setPushNotificationToken:(NSString *)pushNotificationToken {
    _pushNotificationToken = pushNotificationToken;
    
    [self updateUserWithUsername:nil name:nil email:self.email password:self.password fbToken:[FBSession activeSession].accessTokenData.accessToken profileImage:nil about:nil success:nil failure:nil];
}

- (void)setToken:(NSString *)token {
    _token = token;
    
    if (self.token.length > 0) {
        self.tokenExpirationDate = [[NSDate date] dateByAddingTimeInterval:60 * 55];
    } else {
        self.tokenExpirationDate = nil;
    }
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
    if (self.isTokenValid) {
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
		self.email = nil;
		self.password = nil;
		self.token = responseObject[@"token"];
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
		self.password = password;
		self.email = email;
		self.token = responseObject[@"token"];
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
		[[FTBClient client] user:nil success:^(FTBUser *user) {
            NSMutableDictionary *parameters = [NSMutableDictionary new];
            [parameters addEntriesFromDictionary:user.JSONDictionary];
            if (username) parameters[@"username"] = username;
            if (email) parameters[@"email"] = email;
            if (password) parameters[@"password"] = password;
            if (name) parameters[@"name"] = name;
            if (about) parameters[@"about"] = about;
            if (picturePath) parameters[@"picture"] = picturePath;
            if (self.pushNotificationToken.length > 0) parameters[@"apnsToken"] = self.pushNotificationToken;
            if (fbToken) [[FTBClient client].requestSerializer setValue:fbToken forHTTPHeaderField:@"facebook-token"];
            parameters[@"language"] = [NSLocale preferredLanguages][0];
            parameters[@"locale"] = [[NSLocale currentLocale] localeIdentifier];
            parameters[@"timezone"] = [[NSTimeZone defaultTimeZone] name];
            
            void(^completionBlock)() = ^() {
                [[FTBClient client].requestSerializer setValue:nil forHTTPHeaderField:@"facebook-token"];
            };
			
			[[FTBClient client] updateUser:user success:^(id object) {
				if (fbToken.length > 0) {
					[FXKeychain defaultKeychain][kUserFbAuthenticatedKey] = @YES;
				}
				if (email.length > 0) {
					self.email = email;
				}
				if (password.length > 0) {
					self.password = password;
				}
				completionBlock();
				if (success) success(user);
			} failure:^(NSError *error) {
				completionBlock();
				if (error.code == 500) {
					error = [NSError errorWithDomain:kFTErrorDomain code:error.code userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Error: email or username already taken", @"")}];
				}
				if (failure) failure(error);
			}];
        } failure:failure];
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
    self.email = nil;
    self.password = nil;
    self.token = nil;
    [FXKeychain defaultKeychain][kUserFbAuthenticatedKey] = nil;
    
    @try {
        [[FBSession activeSession] closeAndClearTokenInformation];
        [FBSession setActiveSession:nil];
    }
    @catch (NSException *exception) {}
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFTNotificationAuthenticationChanged object:nil];
}

@end
