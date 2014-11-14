//
//  FTAuthenticationManager.m
//  Footbl
//
//  Created by Fernando Saragoça on 8/11/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <FXKeychain/FXKeychain.h>
#import "ErrorHandler.h"
#import "FTAuthenticationManager.h"
#import "FTBuildType.h"
#import "FTImageUploader.h"
#import "FTOperationManager.h"
#import "NSString+Hex.h"
#import "NSString+SHA1.h"
#import "User.h"

static NSString * const kUserEmailKey = @"kUserEmailKey";
static NSString * const kUserIdentifierKey = @"kUserIdentifierKey";
static NSString * const kUserPasswordKey = @"kUserPasswordKey";
static NSString * const kUserFbAuthenticatedKey = @"kUserFbAuthenticatedKey";

NSString * FBAuthenticationManagerGeneratePasswordWithId(NSString *userId) {
    return [NSString stringWithFormat:@"%@%@", userId, [FTOperationManager sharedManager].signatureKey].sha1;
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
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

#pragma mark - Getters/Setters

@synthesize email = _email;
@synthesize password = _password;

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

- (void)ensureAuthenticationWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
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

- (void)createUserWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[FTOperationManager sharedManager] validateEnvironmentWithSuccess:^(id response) {
        NSString *password = [NSString randomHexStringWithLength:20];
        [[FTOperationManager sharedManager] performOperationWithOptions:FTRequestOptionGroupRequests operations:^{
            [[FTOperationManager sharedManager] POST:[User resourcePath] parameters:@{@"password" : password} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self loginWithEmail:nil password:password success:^(id response) {
                    if (success) success(responseObject);
                } failure:failure];
            } failure:failure];
        }];
    } failure:failure];
}

- (void)loginWithFacebookToken:(NSString *)fbToken success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    BOOL shouldSendNotification = (self.authenticationType == FTAuthenticationTypeNone);
    [[FTOperationManager sharedManager] validateEnvironmentWithSuccess:^(id response) {
        [[FTOperationManager sharedManager] performOperationWithOptions:FTRequestOptionGroupRequests operations:^{
            [[FTOperationManager sharedManager].requestSerializer setValue:fbToken forHTTPHeaderField:@"facebook-token"];
            [[FTOperationManager sharedManager] GET:@"users/me/auth" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                self.email = nil;
                self.password = nil;
                self.token = responseObject[@"token"];
                [FXKeychain defaultKeychain][kUserFbAuthenticatedKey] = @YES;
                [User getMeWithSuccess:^(id response) {
                    [[FTOperationManager sharedManager].requestSerializer setValue:nil forHTTPHeaderField:@"facebook-token"];
                    [self registerForRemoteNotifications];
                    if (shouldSendNotification) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kFTNotificationAuthenticationChanged object:nil];
                    }
                    if (success) success(response);
                } failure:failure];
            } failure:failure];
        }];
    } failure:failure];
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    BOOL shouldSendNotification = (self.authenticationType == FTAuthenticationTypeNone);
    [[FTOperationManager sharedManager] validateEnvironmentWithSuccess:^(id response) {
        [[FTOperationManager sharedManager] performOperationWithOptions:FTRequestOptionGroupRequests operations:^{
            NSMutableDictionary *parameters = [NSMutableDictionary new];
            if (email) parameters[@"email"] = email;
            if (password) parameters[@"password"] = password;
            [[FTOperationManager sharedManager] GET:@"users/me/auth" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                self.password = password;
                self.email = email;
                self.token = responseObject[@"token"];
                [FXKeychain defaultKeychain][kUserFbAuthenticatedKey] = nil;
                [User getMeWithSuccess:^(id response) {
                    [self registerForRemoteNotifications];
                    if (shouldSendNotification) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kFTNotificationAuthenticationChanged object:nil];
                    }
                    if (success) success(response);
                } failure:failure];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (operation.response.statusCode == 403) {
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
                if (failure) failure(operation, error);
            }];
        }];
    } failure:failure];
}

- (void)registerForRemoteNotifications {
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

- (void)updateUserWithUsername:(NSString *)username name:(NSString *)name email:(NSString *)email password:(NSString *)password fbToken:(NSString *)fbToken profileImage:(UIImage *)profileImage about:(NSString *)about success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    void(^updateAccountBlock)(NSString *picturePath) = ^(NSString *picturePath) {
        [User getMeWithSuccess:^(User *user) {
            NSMutableDictionary *parameters = [NSMutableDictionary new];
            [parameters addEntriesFromDictionary:user.dictionaryRepresentation];
            if (username) parameters[@"username"] = username;
            if (email) parameters[@"email"] = email;
            if (password) parameters[@"password"] = password;
            if (name) parameters[@"name"] = name;
            if (about) parameters[@"about"] = about;
            if (picturePath) parameters[@"picture"] = picturePath;
            if (self.pushNotificationToken.length > 0) parameters[@"apnsToken"] = self.pushNotificationToken;
            if (fbToken) [[FTOperationManager sharedManager].requestSerializer setValue:fbToken forHTTPHeaderField:@"facebook-token"];
            parameters[@"language"] = [NSLocale preferredLanguages][0];
            parameters[@"locale"] = [[NSLocale currentLocale] localeIdentifier];
            parameters[@"timezone"] = [[NSTimeZone defaultTimeZone] name];
            
            void(^completionBlock)() = ^() {
                [[FTOperationManager sharedManager].requestSerializer setValue:nil forHTTPHeaderField:@"facebook-token"];
            };
            
            [user updateWithParameters:parameters success:^(User *user) {
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
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                completionBlock();
                if (operation.response.statusCode == 500) {
                    error = [NSError errorWithDomain:kFTErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"Error: email or username already taken", @"")}];
                }
                if (failure) failure(operation, error);
            }];
        } failure:failure];
    };
    
    [FTImageUploader uploadImage:profileImage withSuccess:^(id response) {
        updateAccountBlock(response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        updateAccountBlock(nil);
    }];
}

- (BOOL)isValidPassword:(NSString *)password {
    return [self.password isEqualToString:password];
}

- (void)logout {
    [ErrorHandler sharedInstance].shouldShowError = NO;
    [[[FTOperationManager sharedManager] operationQueue] cancelAllOperations];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ErrorHandler sharedInstance].shouldShowError = YES;
    });
    
    self.email = nil;
    self.password = nil;
    self.token = nil;
    [FXKeychain defaultKeychain][kUserFbAuthenticatedKey] = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserManagedObjectRepresentationKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[FTCoreDataStore privateQueueContext] performBlock:^{
        for (NSString *entity in @[@"Bet", @"Match", @"Team", @"Entry", @"Championship", @"Membership", @"Group", @"CreditRequest", @"User"]) {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entity];
            fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"rid" ascending:YES]];
            NSError *error = nil;
            NSArray *fetchResult = [[FTCoreDataStore privateQueueContext] executeFetchRequest:fetchRequest error:&error];
            if (error) {
                abort();
            }
            [[FTCoreDataStore privateQueueContext] deleteObjects:[NSSet setWithArray:fetchResult]];
        }
        [[FTCoreDataStore privateQueueContext] performSave];
    }];
    
    @try {
        [[FBSession activeSession] closeAndClearTokenInformation];
        [FBSession setActiveSession:nil];
    }
    @catch (NSException *exception) {
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFTNotificationAuthenticationChanged object:nil];
}

@end
