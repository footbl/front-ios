//
//  FootblAPI.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/25/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
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

@end

#pragma mark FootblAPI

@implementation FootblAPI

static NSString * const kAPIBaseURLString = @"https://footbl-development.herokuapp.com";
static NSString * const kAPISignatureKey = @"-f-Z~Nyhq!3&oSP:Do@E(/pj>K)Tza%})Qh= pxJ{o9j)F2.*$+#n}XJ(iSKQnXf";
static NSString * const kAPIAcceptVersion = @"1.0";

static NSString * const kConfigPageSize = @"kConfigPageSize";
static NSString * const kUserEmailKey = @"kUserEmailKey";
static NSString * const kUserIdentifierKey = @"kUserIdentifierKey";
static NSString * const kUserPasswordKey = @"kUserPasswordKey";

NSString * const kAPIIdentifierKey = @"_id";
NSString * const kFootblAPINotificationAuthenticationChanged = @"kFootblAPINotificationAuthenticationChanged";

NSManagedObjectContext * FootblBackgroundManagedObjectContext() {
    return [(AppDelegate *)[UIApplication sharedApplication].delegate backgroundManagedObjectContext];
}

NSManagedObjectContext * FootblManagedObjectContext() {
    return [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
}

void requestSucceedWithBlock(AFHTTPRequestOperation *operation, NSDictionary *parameters, FootblAPISuccessBlock success) {
    SPLog(@"%@ %@", operation.request.HTTPMethod, [operation.request.URL.absoluteString componentsSeparatedByString:@"?"].firstObject ? [operation.request.URL.absoluteString componentsSeparatedByString:@"?"].firstObject : operation.request.URL);
    SPLogVerbose(@"%@\n\n%@", parameters, [operation responseObject]);
    if (success) dispatch_async(dispatch_get_main_queue(), success);
}

void requestFailedWithBlock(AFHTTPRequestOperation *operation, NSDictionary *parameters, NSError *error, FootblAPIFailureBlock failure) {
    SPLogError(@"Error: %@ %@", operation.request.HTTPMethod, [operation.request.URL.absoluteString componentsSeparatedByString:@"?"].firstObject ? [operation.request.URL.absoluteString componentsSeparatedByString:@"?"].firstObject : operation.request.URL);
    SPLog(@"Error: %@\n\n%@\n\n%@", parameters, error, [operation responseString]);
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

#pragma mark - Getters/Setters

@synthesize userEmail = _userEmail;
@synthesize userIdentifier = _userIdentifier;
@synthesize userPassword = _userPassword;

- (NSString *)userEmail {
    return [FXKeychain defaultKeychain][kUserEmailKey];
}

- (NSString *)userIdentifier {
    return [FXKeychain defaultKeychain][kUserIdentifierKey];
}

- (NSString *)userPassword {
    return [FXKeychain defaultKeychain][kUserPasswordKey];
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
        self.currentUser = [User findOrCreateByIdentifier:self.userIdentifier inManagedObjectContext:FootblManagedObjectContext()];
    }
    
    return _currentUser;
}

#pragma mark - Instance Methods

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [self.requestSerializer setValue:kAPIAcceptVersion forHTTPHeaderField:@"Accept-Version"];
        self.operationGroupingDictionary = [NSMutableDictionary new];
        
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        [FXKeychain defaultKeychain][(__bridge id)(kSecAttrAccessible)] = (__bridge id)(kSecAttrAccessibleAlways);
    }
    return self;
}

- (NSString *)generateSignatureWithTimestamp:(float)timestamp transaction:(NSString *)transactionIdentifier {
    return [[NSString stringWithFormat:@"%.00f%@%@", timestamp, transactionIdentifier, kAPISignatureKey] sha1];
}

- (NSMutableDictionary *)generateDefaultParameters {
    float unixTime = roundf((float)[[NSDate date] timeIntervalSince1970] * 1000.f);
    NSString *transactionIdentifier = [NSString randomHexStringWithLength:10];
    
    [self.requestSerializer setValue:[NSString stringWithFormat:@"%.00f", unixTime] forHTTPHeaderField:@"auth-timestamp"];
    [self.requestSerializer setValue:transactionIdentifier forHTTPHeaderField:@"auth-transactionId"];
    [self.requestSerializer setValue:[self generateSignatureWithTimestamp:unixTime transaction:transactionIdentifier] forHTTPHeaderField:@"auth-signature"];
    if ([self isAuthenticated] && self.userToken.length > 0) {
        [self.requestSerializer setValue:self.userToken forHTTPHeaderField:@"auth-token"];
    }
    
    return [@{} mutableCopy];
}

- (void)groupOperationsWithSelector:(SEL)selector block:(dispatch_block_t)block success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    NSString *key = NSStringFromSelector(selector);
    NSMutableArray *queue = (self.operationGroupingDictionary)[key];
    if (queue) {
        if (failure) {
            [queue addObject:@{@"success": success, @"failure" : failure}];
        } else {
            [queue addObject:@{@"success": success}];
        }
        return;
    }
    
    (self.operationGroupingDictionary)[key] = [NSMutableArray new];
    
    if (block) block();
}

- (void)finishGroupedOperationsWithSelector:(SEL)selector error:(NSError *)error {
    NSString *key = NSStringFromSelector(selector);
    NSMutableArray *queue = (self.operationGroupingDictionary)[key];
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

#pragma mark - Config

- (void)updateConfigWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [self ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [self GET:@"/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"pageSize"] forKey:kConfigPageSize];
            [[NSUserDefaults standardUserDefaults] synchronize];
            requestSucceedWithBlock(operation, parameters, success);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

#pragma mark - Users

- (BOOL)isAnonymous {
    return self.userEmail.length == 0 && self.userIdentifier.length > 0;
}

- (BOOL)isAuthenticated {
    return (self.userIdentifier.length > 0 || self.userEmail.length > 0) && self.userPassword.length > 0;
}

- (BOOL)isTokenValid {
    return self.userToken.length > 0 && self.tokenExpirationDate && [[NSDate date] timeIntervalSinceDate:self.tokenExpirationDate] < 0;
}

- (void)createAccountWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
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
    
    if ([self isTokenValid]) {
        success();
        return;
    }
    
    if (self.tokenExpirationDate && [self isAuthenticated]) {
        SPLogVerbose(@"Authentication token expired");
    }
    
    [self groupOperationsWithSelector:@selector(ensureAuthenticationWithSuccess:failure:) block:^{
        void(^loginBlock)() = ^() {
            [self loginWithEmail:self.userEmail identifier:self.userIdentifier password:self.userPassword success:^{
                if (success) success();
                [self finishGroupedOperationsWithSelector:@selector(ensureAuthenticationWithSuccess:failure:) error:nil];
            } failure:^(NSError *error) {
                if (failure) failure(error);
                [self finishGroupedOperationsWithSelector:@selector(ensureAuthenticationWithSuccess:failure:) error:error];
            }];
        };
        
        if ([self isAuthenticated]) {
            loginBlock();
        } else {
            [self createAccountWithSuccess:loginBlock failure:failure];
        }
    } success:success failure:failure];
}

- (void)loginWithEmail:(NSString *)email identifier:(NSString *)identifier password:(NSString *)password success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    NSMutableDictionary *parameters = [self generateDefaultParameters];
    if (email.length > 0) {
        parameters[@"email"] = email;
    } else {
        parameters[kAPIIdentifierKey] = identifier;
    }
    parameters[@"password"] = password;
    
    [self GET:@"users/me/session" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.userToken = responseObject[@"token"];
        self.userIdentifier = responseObject[kAPIIdentifierKey];
#if !TARGET_IPHONE_SIMULATOR
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
#endif
        requestSucceedWithBlock(operation, parameters, success);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        requestFailedWithBlock(operation, parameters, error, failure);
    }];
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [self loginWithEmail:email identifier:nil password:password success:^{
        self.userEmail = email;
        self.userPassword = password;
        if (success) success();
    } failure:failure];
}

- (void)loginWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [self loginWithEmail:nil identifier:self.userIdentifier password:self.userPassword success:success failure:failure];
}

- (void)logout {
    self.userIdentifier = nil;
    self.userEmail = nil;
    self.userPassword = nil;
    self.userToken = nil;
    self.currentUser = nil;
    
    [self.requestSerializer setValue:nil forHTTPHeaderField:@"auth-timestamp"];
    [self.requestSerializer setValue:nil forHTTPHeaderField:@"auth-transactionId"];
    [self.requestSerializer setValue:nil forHTTPHeaderField:@"auth-signature"];
    
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
}

- (void)updateAccountWithUsername:(NSString *)username email:(NSString *)email password:(NSString *)password success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [self ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        parameters[@"username"] = username;
        parameters[@"email"] = email;
        parameters[@"password"] = password;
        parameters[@"language"] = [NSLocale preferredLanguages][0];
        [parameters setValue:[[NSLocale currentLocale] identifier] forKey:@"locale"];
        [parameters setValue:[[NSTimeZone defaultTimeZone] name] forKey:@"timezone"];
        [self PUT:[@"users/" stringByAppendingPathComponent:self.userIdentifier] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            requestSucceedWithBlock(operation, parameters, success);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

@end
