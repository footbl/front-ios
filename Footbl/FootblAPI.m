//
//  FootblAPI.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/25/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <Cloudinary/Cloudinary.h>
#import <FXKeychain/FXKeychain.h>
#import <SPHipster/SPLog.h>
#import "AppDelegate.h"
#import "FootblAPI.h"
#import "NSString+Hex.h"
#import "NSString+SHA1.h"
#import "User.h"

@interface FootblAPI ()

@property (copy, nonatomic) NSString *userToken;
@property (strong, nonatomic) NSDate *tokenExpirationDate;
@property (strong, nonatomic) NSMutableDictionary *operationGroupingDictionary;
@property (assign, nonatomic) BOOL shouldGroup;
@property (assign, nonatomic) BOOL shouldUsePreLaunchBaseUrl;
@property (strong, nonatomic) CLCloudinary *cloudinary;
@property (strong, nonatomic, readonly) NSString *signatureKey;

@end

#pragma mark FootblAPI

@implementation FootblAPI

#if FT_ENVIRONMENT_IS_PRODUCTION
    static NSString * const kAPIBaseURLString = @"https://footbl-production.herokuapp.com";
    static NSString * const kAPISignatureKey = @"~BYq)Ag-;$+r!hrw+b=Wx>MU#t0)*B,h+!#:+>Er|Gp#N)$=|tyU1%|c@yH]I2RR";

    static NSString * const kCloudinaryCloudName = @"hivstsgwo";
    static NSString * const kCloudinaryApiKey = @"987722547954377";
    static NSString * const kCloudinaryApiSecret = @"JDxfvbY3BWwp3Nvnc-zQS6B-jog";
#else
    static NSString * const kAPIBaseURLString = @"https://footbl-development.herokuapp.com";
    static NSString * const kAPISignatureKey = @"-f-Z~Nyhq!3&oSP:Do@E(/pj>K)Tza%})Qh= pxJ{o9j)F2.*$+#n}XJ(iSKQnXf";

    static NSString * const kCloudinaryCloudName = @"he5zfntay";
    static NSString * const kCloudinaryApiKey = @"854175976174894";
    static NSString * const kCloudinaryApiSecret = @"YFawEDfxmujOOGiTUKpAEU5O4eU";
#endif

static NSString * const kAPIPreLaunchSignatureKey = @"sL5hQpGu[W(PUY/8&</*}.|}mSjiW*55oT/ZwJrJo%z+=pX;#R7-P|?.&&~jctR7";
static NSString * const kAPIBasePreLaunchURLString = @"https://footbl-prelaunch.herokuapp.com";

static NSInteger const kAPIVersion = 1;

static NSString * const kConfigPageSize = @"kConfigPageSize";
static NSString * const kUserEmailKey = @"kUserEmailKey";
static NSString * const kUserIdentifierKey = @"kUserIdentifierKey";
static NSString * const kUserPasswordKey = @"kUserPasswordKey";
static NSString * const kUserFbAuthenticatedKey = @"kUserFbAuthenticatedKey";
static NSString * const kUserNotificationTokenKey = @"kUserNotificationTokenKey";

NSString * const FootblAPIErrorDomain = @"FootblAPIErrorDomain";
NSString * const kAPIIdentifierKey = @"_id";
NSString * const kFootblAPINotificationAuthenticationChanged = @"kFootblAPINotificationAuthenticationChanged";
NSString * const kFootblAPINotificationAPIOutdated = @"kFootblAPINotificationAPIOutdated";

NSString * generateFacebookPasswordWithUserId(NSString *userId) {
    return [[NSString stringWithFormat:@"%@%@", userId, [FootblAPI sharedAPI].signatureKey] sha1];
}

NSManagedObjectContext * FootblBackgroundManagedObjectContext() {
    return [(AppDelegate *)[UIApplication sharedApplication].delegate backgroundManagedObjectContext];
}

NSManagedObjectContext * FootblManagedObjectContext() {
    return [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
}

void requestSucceedWithBlock(AFHTTPRequestOperation *operation, NSDictionary *parameters, FootblAPISuccessBlock success) {
    /*
    SPLog(@"%@ %@", operation.request.HTTPMethod, [operation.request.URL.absoluteString componentsSeparatedByString:@"?"].firstObject ? [operation.request.URL.absoluteString componentsSeparatedByString:@"?"].firstObject : operation.request.URL);
    SPLogVerbose(@"%@\n\n%@", parameters, [operation responseObject]);
    */
    if (success) dispatch_async(dispatch_get_main_queue(), success);
}

void requestFailedWithBlock(AFHTTPRequestOperation *operation, NSDictionary *parameters, NSError *error, FootblAPIFailureBlock failure) {
    /*
    SPLogError(@"Error: %@ %@", operation.request.HTTPMethod, [operation.request.URL.absoluteString componentsSeparatedByString:@"?"].firstObject ? [operation.request.URL.absoluteString componentsSeparatedByString:@"?"].firstObject : operation.request.URL);
    SPLog(@"Error: %@\n\n%@\n\n%@", parameters, error, [operation responseString]);
    */
    if (failure) dispatch_async(dispatch_get_main_queue(), ^{
        failure(error);
    });
}

void SaveManagedObjectContext(NSManagedObjectContext *managedObjectContext) {
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[error localizedFailureReason] userInfo:@{NSUnderlyingErrorKey: error}];
        }
    }
}

#pragma mark - Class Methods

+ (instancetype)sharedAPI {
    static FootblAPI *_sharedAPI = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedAPI = [[self alloc] initWithBaseURL:[NSURL URLWithString:kAPIBaseURLString]];
    });
    
    return _sharedAPI;
}

+ (void)performOperationWithoutGrouping:(void (^)())block {
    [FootblAPI sharedAPI].shouldGroup = NO;
    if (block) block();
    [FootblAPI sharedAPI].shouldGroup = YES;
}

#pragma mark - Getters/Setters

@synthesize userEmail = _userEmail;
@synthesize userIdentifier = _userIdentifier;
@synthesize userPassword = _userPassword;
@synthesize pushNotificationToken = _pushNotificationToken;

- (NSString *)userEmail {
    return [FXKeychain defaultKeychain][kUserEmailKey];
}

- (NSString *)userIdentifier {
    return [FXKeychain defaultKeychain][kUserIdentifierKey];
}

- (NSString *)userPassword {
    return [FXKeychain defaultKeychain][kUserPasswordKey];
}

- (NSString *)signatureKey {
    return self.shouldUsePreLaunchBaseUrl ? kAPIPreLaunchSignatureKey : kAPISignatureKey;
}

- (void)setUserEmail:(NSString *)userEmail {
    _userEmail = userEmail;
    [FXKeychain defaultKeychain][kUserEmailKey] = userEmail;
}

- (void)setUserIdentifier:(NSString *)userIdentifier {
    _userIdentifier = userIdentifier;
    
    [FXKeychain defaultKeychain][kUserIdentifierKey] = userIdentifier;
}

- (void)setUserPassword:(NSString *)userPassword {
    _userPassword = userPassword;
    
    [FXKeychain defaultKeychain][kUserPasswordKey] = userPassword;
}

- (void)setUserToken:(NSString *)userToken {
    _userToken = userToken;
    
    [self setTokenExpirationDate:[[NSDate date] dateByAddingTimeInterval:60 * 55]]; // 55 minutes
}

- (User *)currentUser {
    if (_currentUser) {
        return _currentUser;
    }
    
    if (self.userIdentifier) {
        self.currentUser = [User findOrCreateByIdentifier:self.userIdentifier inManagedObjectContext:FootblBackgroundManagedObjectContext()];
        SaveManagedObjectContext(FootblBackgroundManagedObjectContext());
    }
    
    return _currentUser;
}

- (NSInteger)responseLimit {
    return 20;
}

- (NSString *)pushNotificationToken {
    if (!_pushNotificationToken) {
        _pushNotificationToken = [FXKeychain defaultKeychain][kUserNotificationTokenKey];
    }
    
    return [[[_pushNotificationToken uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (void)setPushNotificationToken:(NSString *)pushNotificationToken {
    _pushNotificationToken = pushNotificationToken;
    
    [FXKeychain defaultKeychain][kUserNotificationTokenKey] = self.pushNotificationToken;
    
    [[User currentUser] updateWithSuccess:^{
        [self updateAccountWithUsername:nil name:nil email:nil password:nil fbToken:nil profileImage:nil about:nil success:nil failure:nil];
    } failure:nil];
}

- (NSURL *)baseURL {
    if (self.shouldUsePreLaunchBaseUrl) {
        return [NSURL URLWithString:kAPIBasePreLaunchURLString];
    } else {
        return [super baseURL];
    }
}

#pragma mark - New methods

- (void)startOperationWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters options:(FootblRequestOption)options constructingResponse:(id)constructingResponse success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    BOOL shouldAutoPage = (options & FootblRequestOptionShouldAutoPage);
    BOOL authenticationRequired = (options & FootblRequestOptionAuthenticationRequired);
    BOOL shouldGroup = (options & FootblRequestOptionShouldGroup);
    NSMutableString *key = [URLString mutableCopy];
    
    void(^requestBlock)() = ^() {
        NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
        AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id response) {
            if (!shouldAutoPage || !response || ![response isKindOfClass:[NSArray class]]) {
                if (shouldGroup) {
                    [self finishGroupedOperationsWithKey:key response:response error:nil];
                } else {
                    if (success) success(operation, response);
                }
                return;
            }
            
            NSArray *responseArray = response;
            if (constructingResponse) {
                responseArray = [constructingResponse arrayByAddingObjectsFromArray:responseArray];
            }
            if ([response count] == self.responseLimit) {
                NSMutableDictionary *nextPageParameters = [parameters mutableCopy];
                nextPageParameters[@"page"] = @([parameters[@"page"] integerValue] + 1);
                [self startOperationWithMethod:method URLString:URLString parameters:nextPageParameters options:options constructingResponse:responseArray success:success failure:failure];
            } else if (shouldGroup) {
                [self finishGroupedOperationsWithKey:key response:responseArray error:nil];
            } else if (success) {
                success(operation, responseArray);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (shouldGroup) {
                [self finishGroupedOperationsWithKey:key error:error];
            } else if (failure) {
                failure(operation, error);
            }
        }];
        [self.operationQueue addOperation:operation];
    };
    
    void(^groupBlock)() = ^() {
        if (!shouldGroup || ([parameters[@"page"] integerValue] > 0 && shouldAutoPage)) {
            requestBlock();
            return;
        }
        
        for (NSString *parameter in parameters.allKeys) {
            if (![parameter isEqualToString:@"page"]) {
                [key appendFormat:@"%lu", [parameters[parameter] hash]];
            }
        }
        
        [self groupOperationsWithKey:key block:requestBlock success:^(id response) {
            if (success) success(nil, response);
        } failure:^(NSError *error) {
            if (failure) failure(nil, error);
        }];
    };
    
    if (authenticationRequired) {
        [self ensureAuthenticationWithSuccess:^{
            [self generateRequestHeaders];
            groupBlock();
        } failure:^(NSError *error) {
            if (failure) failure(nil, error);
        }];
    }
}

- (void)GET:(NSString *)URLString parameters:(NSDictionary *)parameters options:(FootblRequestOption)options success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [self startOperationWithMethod:@"GET" URLString:URLString parameters:parameters options:options constructingResponse:nil success:success failure:failure];
}

- (void)POST:(NSString *)URLString parameters:(NSDictionary *)parameters options:(FootblRequestOption)options success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [self startOperationWithMethod:@"POST" URLString:URLString parameters:parameters options:options constructingResponse:nil success:success failure:failure];
}

- (void)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters options:(FootblRequestOption)options success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [self startOperationWithMethod:@"PUT" URLString:URLString parameters:parameters options:options constructingResponse:nil success:success failure:failure];
}

- (void)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters options:(FootblRequestOption)options success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [self startOperationWithMethod:@"DELETE" URLString:URLString parameters:parameters options:options constructingResponse:nil success:success failure:failure];
}

#pragma mark - Instance Methods

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        self.operationGroupingDictionary = [NSMutableDictionary new];
        self.shouldGroup = YES;
        self.shouldUsePreLaunchBaseUrl = NO;
        
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        [FXKeychain defaultKeychain][(__bridge id)(kSecAttrAccessible)] = (__bridge id)(kSecAttrAccessibleAlways);
        
        self.cloudinary = [CLCloudinary new];
        self.cloudinary.config[@"cloud_name"] = kCloudinaryCloudName;
        self.cloudinary.config[@"api_key"] = kCloudinaryApiKey;
        self.cloudinary.config[@"api_secret"] = kCloudinaryApiSecret;
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [self updateConfigWithSuccess:^{
                
            } failure:^(NSError *error) {
                
            }];
        }];
    }
    return self;
}

- (FootblAuthenticationType)authenticationType {
    FBSessionState currentFbState = [FBSession activeSession].state;
    if (currentFbState != FBSessionStateClosed && currentFbState != FBSessionStateClosedLoginFailed && [[FXKeychain defaultKeychain][kUserFbAuthenticatedKey] boolValue]) {
        return FootblAuthenticationTypeFacebook;
    } else if (self.userEmail.length > 0 && self.userPassword.length > 0) {
        return FootblAuthenticationTypeEmailPassword;
    } else if (self.userEmail.length == 0 && self.userIdentifier.length > 0 && self.userPassword.length > 0) {
        return FootblAuthenticationTypeAnonymous;
    }
    
    return FootblAuthenticationTypeNone;
}

- (void)generateRequestHeaders {
    float unixTime = roundf((float)[[NSDate date] timeIntervalSince1970] * 1000.f);
    NSString *transactionIdentifier = [NSString randomHexStringWithLength:10];
    
    [self.requestSerializer setValue:[NSString stringWithFormat:@"%.00f", unixTime] forHTTPHeaderField:@"auth-timestamp"];
    [self.requestSerializer setValue:transactionIdentifier forHTTPHeaderField:@"auth-transactionId"];
    [self.requestSerializer setValue:[self generateSignatureWithTimestamp:unixTime transaction:transactionIdentifier] forHTTPHeaderField:@"auth-signature"];
    if ([self isAuthenticated] && self.userToken.length > 0) {
        [self.requestSerializer setValue:self.userToken forHTTPHeaderField:@"auth-token"];
    }
}

- (NSString *)generateSignatureWithTimestamp:(float)timestamp transaction:(NSString *)transactionIdentifier {
    return [[NSString stringWithFormat:@"%.00f%@%@", timestamp, transactionIdentifier, self.signatureKey] sha1];
}

- (NSMutableDictionary *)generateDefaultParameters {
    [self generateRequestHeaders];
    return [@{} mutableCopy];
}

- (void)groupOperationsWithKey:(id)key block:(dispatch_block_t)block success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    if (!self.shouldGroup) {
        if (block) block();
        return;
    }
    
    NSMutableArray *queue = self.operationGroupingDictionary[key];
    if (!queue) {
        queue = [NSMutableArray new];
    }
    
    if (success && failure) {
        [queue addObject:@{@"success": success, @"failure" : failure}];
    } else if (success) {
        [queue addObject:@{@"success": success}];
    } else if (failure) {
        [queue addObject:@{@"failure": failure}];
    }
    
    self.operationGroupingDictionary[key] = queue;
    
    if (block && queue.count == 1) block();
}

- (void)finishGroupedOperationsWithKey:(id)key response:(id)response error:(NSError *)error {
    NSMutableArray *queue = self.operationGroupingDictionary[key];
    for (NSDictionary *queuedRequest in queue) {
        if (error) {
            FootblAPIFailureBlock block = queuedRequest[@"failure"];
            if (block) block(error);
        } else {
            FootblAPISuccessWithResponseBlock block = queuedRequest[@"success"];
            if (block) block(response);
        }
    }
    [self.operationGroupingDictionary removeObjectForKey:key];
}

- (void)finishGroupedOperationsWithKey:(id)key error:(NSError *)error {
    NSMutableArray *queue = self.operationGroupingDictionary[key];
    for (NSDictionary *queuedRequest in queue) {
        if (error) {
            FootblAPIFailureBlock block = queuedRequest[@"failure"];
            if (block) block(error);
        } else {
            FootblAPISuccessBlock block = queuedRequest[@"success"];
            if (block) block();
        }
    }
    [self.operationGroupingDictionary removeObjectForKey:key];
}

- (void)uploadImage:(UIImage *)image withCompletionBlock:(void (^)(NSString *response, NSError *error))completionBlock {
    CLUploader *uploader = [[CLUploader alloc] init:self.cloudinary delegate:nil];
    [uploader upload:UIImageJPEGRepresentation(image, 1.0) options:@{} withCompletion:^(NSDictionary *successResult, NSString *errorResult, NSInteger code, id context) {
        if (completionBlock) completionBlock(successResult[@"url"], nil);
    } andProgress:nil];
}

#pragma mark - Config

- (void)updateConfigWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    NSMutableDictionary *parameters = [self generateDefaultParameters];
    [self groupOperationsWithKey:@"config" block:^{
        [self GET:@"/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"pageSize"] forKey:kConfigPageSize];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSInteger serverVersion = [responseObject[@"version"] integerValue];
            NSError *error = nil;
            if (serverVersion < kAPIVersion) {
                if (![self.baseURL.absoluteString isEqualToString:kAPIBasePreLaunchURLString]) {
                    self.shouldUsePreLaunchBaseUrl = YES;
                    [FootblAPI performOperationWithoutGrouping:^{
                       [self updateConfigWithSuccess:success failure:failure];
                    }];
                    return;
                } else {
                    error = [NSError errorWithDomain:FootblAPIErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @""}];
                }
            } else if (serverVersion > kAPIVersion) {
                error = [NSError errorWithDomain:FootblAPIErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @""}];
            }
            
            if (error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kFootblAPINotificationAPIOutdated object:nil];
                [self finishGroupedOperationsWithKey:@"config" error:error];
            } else {
                requestSucceedWithBlock(operation, parameters, nil);
                [self finishGroupedOperationsWithKey:@"config" error:nil];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, nil);
            [self finishGroupedOperationsWithKey:@"config" error:error];
        }];
    } success:success failure:failure];
}

#pragma mark - Users

- (BOOL)isAnonymous {
    return self.authenticationType == FootblAuthenticationTypeAnonymous;
}

- (BOOL)isAuthenticated {
    return self.authenticationType != FootblAuthenticationTypeNone;
}

- (BOOL)isTokenValid {
    return self.userToken.length > 0 && self.tokenExpirationDate && [[NSDate date] timeIntervalSinceDate:self.tokenExpirationDate] < 0;
}

- (void)createAccountWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    if (self.authenticationType == FootblAuthenticationTypeAnonymous) {
        if (success) success();
        return;
    }
    
    NSMutableDictionary *parameters = [self generateDefaultParameters];
    parameters[@"password"] = [NSString randomHexStringWithLength:20];
    [self POST:@"users" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.userIdentifier = responseObject[kAPIIdentifierKey];
        self.userPassword = parameters[@"password"];
        self.userEmail = nil;
        requestSucceedWithBlock(operation, parameters, success);
        [[NSNotificationCenter defaultCenter] postNotificationName:kFootblAPINotificationAuthenticationChanged object:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        requestFailedWithBlock(operation, parameters, error, failure);
    }];
}

- (void)ensureAuthenticationWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    if (!success) {
        return;
    }
    
    if (self.authenticationType == FootblAuthenticationTypeNone) {
        if (failure) failure(nil);
    }
    
    if ([self isTokenValid]) {
        success();
        return;
    }
    
    if (self.tokenExpirationDate && [self isAuthenticated]) {
        SPLogVerbose(@"Authentication token expired");
    }
    
    NSString *key = NSStringFromSelector(@selector(ensureAuthenticationWithSuccess:failure:));
    [self groupOperationsWithKey:key block:^{
        void(^loginBlock)(BOOL useFacebook) = ^(BOOL useFacebook) {
            [self loginWithEmail:self.userEmail identifier:self.userIdentifier password:self.userPassword fbToken:useFacebook ? [FBSession activeSession].accessTokenData.accessToken : nil success:^{
                [self finishGroupedOperationsWithKey:key error:nil];
            } failure:^(NSError *error) {
                [self finishGroupedOperationsWithKey:key error:error];
            }];
        };
        
        void(^failureBlock)(NSError *error) = ^(NSError *error) {
            NSMutableArray *queue = self.operationGroupingDictionary[key];
            for (NSDictionary *queuedRequest in queue) {
                FootblAPIFailureBlock block = queuedRequest[@"failure"];
                if (block) block(error);
            }
            [self.operationGroupingDictionary removeObjectForKey:key];
        };
        
        if (self.isAuthenticated && (self.authenticationType != FootblAuthenticationTypeFacebook || (([FBSession activeSession].accessTokenData.accessToken.length > 0) && [[FXKeychain defaultKeychain][kUserFbAuthenticatedKey] boolValue]))) {
            loginBlock(self.authenticationType == FootblAuthenticationTypeFacebook);
        } else {
            __block BOOL facebookHandled = NO;
            switch (self.authenticationType) {
                case FootblAuthenticationTypeAnonymous:
                case FootblAuthenticationTypeEmailPassword:
                    loginBlock(NO);
                    break;
                case FootblAuthenticationTypeFacebook: {
                    [self authenticateFacebookWithCompletion:^(FBSession *session, FBSessionState status, NSError *error) {
                        if ([FBSession activeSession].accessTokenData.accessToken.length > 0 && !facebookHandled) {
                            loginBlock(YES);
                            facebookHandled = YES;
                        } else if (error && !facebookHandled) {
                            [self finishGroupedOperationsWithKey:key error:error];
                            facebookHandled = YES;
                        }
                    }];
                    break;
                }
                default:
                    failureBlock(nil);
                    break;
            }
        }
    } success:success failure:failure];
}

- (void)loginWithEmail:(NSString *)email identifier:(NSString *)identifier password:(NSString *)password fbToken:(NSString *)fbToken success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    NSMutableDictionary *parameters = [self generateDefaultParameters];
    if (fbToken.length > 0) {
        [self.requestSerializer setValue:fbToken forHTTPHeaderField:@"facebook-token"];
    } else if (password.length > 0 && (email.length > 0 || identifier.length > 0)) {
        [self.requestSerializer setValue:nil forHTTPHeaderField:@"facebook-token"];
        if (email.length > 0) {
            parameters[@"email"] = email;
        } else {
            parameters[kAPIIdentifierKey] = identifier;
        }
        parameters[@"password"] = password;
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (failure) failure([NSError errorWithDomain:FootblAPIErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"FootblAPI error: unknown error", @"")}]);
        });
        return;
    }
    
    [self updateConfigWithSuccess:^{
        [self GET:@"users/me/session" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.userToken = responseObject[@"token"];
            self.userIdentifier = responseObject[kAPIIdentifierKey];
#if !TARGET_IPHONE_SIMULATOR
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
#endif
            [self.requestSerializer setValue:nil forHTTPHeaderField:@"facebook-token"];
            
            if (fbToken.length > 0) {
                [FXKeychain defaultKeychain][kUserFbAuthenticatedKey] = @YES;
            } else {
                [FXKeychain defaultKeychain][kUserFbAuthenticatedKey] = nil;
            }
            
            self.currentUser = [User findOrCreateByIdentifier:self.userIdentifier inManagedObjectContext:FootblBackgroundManagedObjectContext()];
            SaveManagedObjectContext(FootblBackgroundManagedObjectContext());
            
            requestSucceedWithBlock(operation, parameters, success);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kFootblAPINotificationAuthenticationChanged object:nil];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (operation.response.statusCode == 403) {
                if (self.isAuthenticated) {
                    error = [NSError errorWithDomain:FootblAPIErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"Error: authentication error, need to login again", @"")}];
                    [self logout];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kFootblAPINotificationAuthenticationChanged object:nil];
                } else {
                    error = [NSError errorWithDomain:FootblAPIErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"Error: invalid username or password", @"")}];
                }
            }
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [self loginWithEmail:email identifier:nil password:password fbToken:nil success:^{
        self.userEmail = email;
        self.userPassword = password;
        if (success) success();
    } failure:failure];
}

- (void)loginWithFacebookToken:(NSString *)facebookToken success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [self loginWithEmail:nil identifier:nil password:nil fbToken:facebookToken success:success failure:failure];
}

- (void)authenticateFacebookWithCompletion:(void (^)(FBSession *session, FBSessionState status, NSError *error))completionBlock {
    if ([FBSession activeSession].isOpen && [FBSession activeSession].accessTokenData.accessToken.length > 0) {
        completionBlock([FBSession activeSession], [FBSession activeSession].state, nil);
        return;
    }
    
    NSString *key = NSStringFromSelector(@selector(authenticateFacebookWithCompletion:));
    [self groupOperationsWithKey:key block:^{
        void(^handoverLoginOption)() = ^() {
            [FBSession openActiveSessionWithReadPermissions:FB_READ_PERMISSIONS allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                if (error) {
                    [self finishGroupedOperationsWithKey:key error:error];
                } else {
                    [self finishGroupedOperationsWithKey:key error:nil];
                }
            }];
        };
        
        @try {
            [[FBSession activeSession] openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (status == FBSessionStateClosedLoginFailed) {
                        handoverLoginOption();
                    } else {
                        [[FBSession activeSession] requestNewReadPermissions:FB_READ_PERMISSIONS completionHandler:^(FBSession *session, NSError *error) {
                            if (error) {
                                [self finishGroupedOperationsWithKey:key error:error];
                            } else {
                                [self finishGroupedOperationsWithKey:key error:nil];
                            }
                        }];
                    }
                });
            }];
        }
        @catch (NSException *exception) {
            handoverLoginOption();
        }
    } success:^{
        if (completionBlock) completionBlock([FBSession activeSession], [FBSession activeSession].state, nil);
    } failure:^(NSError *error) {
        if (completionBlock) completionBlock([FBSession activeSession], [FBSession activeSession].state, error);
    }];
}

- (void)logout {
    if (!self.isAuthenticated) {
        return;
    }
    
    [[self operationQueue] cancelAllOperations];
    
    self.userIdentifier = nil;
    self.userEmail = nil;
    self.userPassword = nil;
    self.userToken = nil;
    self.currentUser = nil;
    [FXKeychain defaultKeychain][kUserFbAuthenticatedKey] = nil;
    
    [self.requestSerializer setValue:nil forHTTPHeaderField:@"auth-timestamp"];
    [self.requestSerializer setValue:nil forHTTPHeaderField:@"auth-transactionId"];
    [self.requestSerializer setValue:nil forHTTPHeaderField:@"auth-signature"];
    [self.requestSerializer setValue:nil forHTTPHeaderField:@"facebook-token"];
    
    [FootblBackgroundManagedObjectContext() performBlock:^{
        for (NSString *entity in @[@"Comment", @"Match", @"Team", @"Championship", @"Group", @"Bet", @"Wallet", @"User", @"Membership"]) {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entity];
            fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"rid" ascending:YES]];
            NSError *error = nil;
            NSArray *fetchResult = [FootblBackgroundManagedObjectContext() executeFetchRequest:fetchRequest error:&error];
            if (error) {
                SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            for (NSManagedObject *object in fetchResult) {
                [FootblBackgroundManagedObjectContext() deleteObject:object];
            }
        }
        SaveManagedObjectContext(FootblBackgroundManagedObjectContext());
    }];
    
    @try {
        [[FBSession activeSession] closeAndClearTokenInformation];
    }
    @catch (NSException *exception) {
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFootblAPINotificationAuthenticationChanged object:nil];
}

- (void)updateAccountWithUsername:(NSString *)username name:(NSString *)name email:(NSString *)email password:(NSString *)password fbToken:(NSString *)fbToken profileImage:(UIImage *)profileImage about:(NSString *)about success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    void(^requestBlock)(NSString *picturePath) = ^(NSString *picturePath) {
        [[User currentUser] updateWithSuccess:^{
            NSMutableDictionary *parameters = [self generateDefaultParameters];
            [parameters addEntriesFromDictionary:[[User currentUser] dictionaryRepresentation]];
            if (username) parameters[@"username"] = username;
            if (email) parameters[@"email"] = email;
            if (password) parameters[@"password"] = password;
            if (name) parameters[@"name"] = name;
            if (about) parameters[@"about"] = about;
            if (picturePath) parameters[@"picture"] = picturePath;
            if (self.pushNotificationToken.length > 0) parameters[@"apnsToken"] = self.pushNotificationToken;
            if (fbToken) [self.requestSerializer setValue:fbToken forHTTPHeaderField:@"facebook-token"];
            parameters[@"language"] = [NSLocale preferredLanguages][0];
            parameters[@"locale"] = [[NSLocale currentLocale] identifier];
            parameters[@"timezone"] = [[NSTimeZone defaultTimeZone] name];
            
            [self PUT:[@"users/" stringByAppendingPathComponent:self.userIdentifier] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if (fbToken.length > 0) {
                    [FXKeychain defaultKeychain][kUserFbAuthenticatedKey] = @YES;
                }
                if (email.length > 0) {
                    self.userEmail = email;
                }
                if (password.length > 0) {
                    self.userPassword = password;
                }
                [self.requestSerializer setValue:nil forHTTPHeaderField:@"facebook-token"];
                [FootblBackgroundManagedObjectContext() performBlock:^{
                    [[User currentUser].editableObject updateWithData:responseObject];
                    SaveManagedObjectContext(FootblBackgroundManagedObjectContext());
                    requestSucceedWithBlock(operation, parameters, success);
                }];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self.requestSerializer setValue:nil forHTTPHeaderField:@"facebook-token"];
                if (operation.response.statusCode == 500) {
                    error = [NSError errorWithDomain:FootblAPIErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"Error: email or username already taken", @"")}];
                }
                requestFailedWithBlock(operation, parameters, error, failure);
            }];
        } failure:failure];
    };
    
    if (profileImage) {
        [self uploadImage:profileImage withCompletionBlock:^(NSString *response, NSError *error) {
            requestBlock(response);
        }];
    } else {
        requestBlock(nil);
    }
}

@end
