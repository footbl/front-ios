//
//  FootblAPI.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/25/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SPHipster/SPLog.h>
#import "FootblAPI.h"
#import "NSString+Hex.h"
#import "NSString+SHA1.h"

#pragma mark FootblAPI

@implementation FootblAPI

static NSString * const kAPIBaseURLString = @"https://footbl-development.herokuapp.com";
static NSString * const kAPISignatureKey = @"-f-Z~Nyhq!3&oSP:Do@E(/pj>K)Tza%})Qh= pxJ{o9j)F2.*$+#n}XJ(iSKQnXf";
static NSString * const kAPIAcceptVersion = @"1.0";

static NSString * const kTestUserID = @"5331d9661ce75b040098824c";
static NSString * const kTestUserPassword = @"123456";
static NSString * const kTestUserToken = @"1e9468b8520e46e70a089d5742dcad6a5f430b71";

static void requestSucceedWithBlock(id responseObject, FootblAPISuccessBlock success) {
    SPLogVerbose(@"%@", responseObject);
    if (success) success();
}

static void requestFailedWithBlock(AFHTTPRequestOperation *operation, NSDictionary *parameters, NSError *error, FootblAPIFailureBlock failure) {
    SPLogError(@"\n%@\n\n%@\n\n%@", parameters, error, [operation responseString]);
    if (failure) failure(error);
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

#pragma mark - Instance Methods

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [self.requestSerializer setValue:kAPIAcceptVersion forHTTPHeaderField:@"Accept-Version"];
    }
    return self;
}

- (NSString *)generateSignatureWithTimestamp:(float)timestamp transaction:(NSString *)transactionIdentifier {
    return [[NSString stringWithFormat:@"%.00f%@%@", timestamp, transactionIdentifier, kAPISignatureKey] sha1];
}

- (NSMutableDictionary *)sharedParameters {
    float unixTime = roundf((float)[[NSDate date] timeIntervalSince1970] * 1000.f);
    NSString *transactionIdentifier = [NSString randomStringWithLength:10];
    
    NSMutableDictionary *parameters = [@{} mutableCopy];
    [parameters setObject:[NSString stringWithFormat:@"%.00f", unixTime] forKey:@"timestamp"];
    [parameters setObject:transactionIdentifier forKey:@"transactionId"];
    [parameters setObject:[self generateSignatureWithTimestamp:unixTime transaction:transactionIdentifier] forKey:@"signature"];
    [parameters setObject:kTestUserToken forKey:@"token"];
    
    return parameters;
}

#pragma mark - Users

- (void)createAccountWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    NSMutableDictionary *parameters = [self sharedParameters];
    [parameters setObject:[NSString randomStringWithLength:20] forKey:@"password"];
    [self POST:@"users" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        requestSucceedWithBlock(responseObject, success);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        requestFailedWithBlock(operation, parameters, error, failure);
    }];
}

- (void)loginWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    NSMutableDictionary *parameters = [self sharedParameters];
    [parameters setObject:kTestUserID forKey:@"_id"];
    [parameters setObject:kTestUserPassword forKey:@"password"];
    
    [self GET:@"users/me/session" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        requestSucceedWithBlock(responseObject, success);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        requestFailedWithBlock(operation, parameters, error, failure);
    }];
}

- (void)updateAccountWithUsername:(NSString *)username email:(NSString *)email password:(NSString *)password success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    NSMutableDictionary *parameters = [self sharedParameters];
    [parameters setObject:username forKey:@"username"];
    [parameters setObject:email forKey:@"email"];
    [parameters setObject:password forKey:@"password"];
    [self PUT:[@"users/" stringByAppendingPathComponent:kTestUserID] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        requestSucceedWithBlock(responseObject, success);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        requestFailedWithBlock(operation, parameters, error, failure);
    }];
}

@end
