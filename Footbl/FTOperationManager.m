//
//  FTOperationManager.m
//  Footbl
//
//  Created by Fernando Saragoça on 8/7/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "ErrorHandler.h"
#import "FTAuthenticationManager.h"
#import "FTModel.h"
#import "FTOperationManager.h"
#import "FTRequestSerializer.h"
#import "NSURLRequest+FTAuthentication.h"
#import "NSURLRequest+FTRequestOptions.h"

NSString * const kFTNotificationAPIOutdated = @"kFootblAPINotificationAPIOutdated";
NSString * const kFTNotificationAuthenticationChanged = @"kFootblAPINotificationAuthenticationChanged";

@interface FTOperationManager ()

@property (strong, nonatomic) NSMutableDictionary *groupingDictionary;

@end

#pragma mark FootblAPIOperationManager

@implementation FTOperationManager

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

- (id)init {
    self = [super init];
    if (self) {
        _responseLimit = 20;
        self.requestSerializer = [FTRequestSerializer serializer];
        self.environment = FTEnvironmentDevelopment;
    }
    return self;
}

- (NSURL *)baseURL {
    switch ([FTOperationManager sharedManager].environment) {
        case FTEnvironmentDevelopment:
            return [NSURL URLWithString:@"https://footbl-development.herokuapp.com"];
        case FTEnvironmentPreLaunch:
            return [NSURL URLWithString:@"https://footbl-prelaunch.herokuapp.com"];
        case FTEnvironmentProduction:
            return [NSURL URLWithString:@"https://footbl-production.herokuapp.com"];
    }
}

- (NSString *)signatureKey {
    switch ([FTOperationManager sharedManager].environment) {
        case FTEnvironmentDevelopment:
            return @"-f-Z~Nyhq!3&oSP:Do@E(/pj>K)Tza%})Qh= pxJ{o9j)F2.*$+#n}XJ(iSKQnXf";
        case FTEnvironmentPreLaunch:
            return @"sL5hQpGu[W(PUY/8&</*}.|}mSjiW*55oT/ZwJrJo%z+=pX;#R7-P|?.&&~jctR7";
        case FTEnvironmentProduction:
            return @"~BYq)Ag-;$+r!hrw+b=Wx>MU#t0)*B,h+!#:+>Er|Gp#N)$=|tyU1%|c@yH]I2RR";
    }
}

- (NSUInteger)apiVersion {
    switch ([FTOperationManager sharedManager].environment) {
        case FTEnvironmentDevelopment:
            return 1;
        case FTEnvironmentPreLaunch:
            return 1;
        case FTEnvironmentProduction:
            return 1;
    }
}

- (NSMutableDictionary *)groupingDictionary {
    if (!_groupingDictionary) {
        _groupingDictionary = [NSMutableDictionary new];
    }
    return _groupingDictionary;
}

#pragma mark - Instance Methods

- (void)performOperationWithOptions:(FTRequestOptions)options operations:(void (^)())operations {
    FTRequestSerializer *requestSerializer = (FTRequestSerializer *)self.requestSerializer;
    requestSerializer.options = options;
    if (operations) operations();
    requestSerializer.options = requestSerializer.defaultOptions;
}

- (AFHTTPRequestOperation *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    FTRequestSerializer *requestSerializer = (FTRequestSerializer *)self.requestSerializer;
    BOOL autoPageEnabled = (requestSerializer.options & FTRequestOptionAutoPage);
    
    __block NSMutableArray *responseArray = [NSMutableArray new];
    __block void(^pagingBlock)(AFHTTPRequestOperation *operation, NSArray *responseObject);
    __block void(^weakPagingBlock)(AFHTTPRequestOperation *operation, NSArray *responseObject);
    
    pagingBlock = ^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
        [responseArray addObjectsFromArray:responseObject];
        if (responseObject.count == 20) {
            NSMutableDictionary *newParamaters = [parameters mutableCopy];
            if (!newParamaters) {
                newParamaters = [NSMutableDictionary new];
            }
            newParamaters[@"page"] = @(operation.request.page + 1);
            [self GET:URLString parameters:newParamaters success:weakPagingBlock failure:failure];
        } else if (success) {
            success(operation, responseArray);
        }
    };
    weakPagingBlock = [pagingBlock copy];
    
    return [super GET:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (autoPageEnabled && [responseObject isKindOfClass:[NSArray class]]) {
            pagingBlock(operation, responseObject);
        } else {
            if (success) success(operation, responseObject);
        }
    } failure:failure];
}

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)request success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    if (!request) {
        return nil;
    }
    
    FTRequestSerializer *requestSerializer = (FTRequestSerializer *)self.requestSerializer;
    FTRequestOptions options = requestSerializer.options;
    BOOL authenticationRequired = (options & FTRequestOptionAuthenticationRequired);
    AFHTTPRequestOperation * (^groupBlock)() = ^() {
        AFHTTPRequestOperation *operation = [super HTTPRequestOperationWithRequest:[request signedRequest] success:success failure:failure];
        return [self groupOperation:operation withBlock:^(FTOperationResponseBlock finishedBlock) {
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                finishedBlock(responseObject, nil);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                finishedBlock(nil, error);
            }];
        } completionBlock:^(id response, NSError *error) {
            if (success && !error) {
                success(operation, response);
            } else if (failure && error) {
                failure(operation, error);
            }
        }];
    };
    
    if (!authenticationRequired || [FTAuthenticationManager sharedManager].isTokenValid) {
        return groupBlock();
    } else {
        [[FTAuthenticationManager sharedManager] ensureAuthenticationWithSuccess:^(id response) {
            AFHTTPRequestOperation *operation = groupBlock();
            [self.operationQueue addOperation:operation];
        } failure:failure];
        return nil;
    }
}

- (AFHTTPRequestOperation *)groupOperation:(AFHTTPRequestOperation *)operation withBlock:(void (^)(FTOperationResponseBlock finishedBlock))runBlock completionBlock:(void (^)(id response, NSError *error))completionBlock {
    if (!completionBlock) {
        return operation;
    }
    
    if (!(operation.request.options & FTRequestOptionGroupRequests)) {
        return operation;
    }
    
    NSString *key = operation.request.URL.absoluteString;
    NSMutableArray *queue = self.groupingDictionary[key];
    if (!queue) {
        queue = [NSMutableArray new];
    }
    [queue addObject:completionBlock];
    self.groupingDictionary[key] = queue;
    
    if (runBlock && queue.count == 1) {
        FTOperationResponseBlock finishedBlock = ^(id response, NSError *error) {
            NSMutableArray *queue = self.groupingDictionary[key];
            for (FTOperationResponseBlock queuedRequest in queue) {
                queuedRequest(response, error);
            }
            [self.groupingDictionary removeObjectForKey:key];
        };
        runBlock(finishedBlock);
        return operation;
    }
    
    return nil;
}

- (void)validateEnvironmentWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[FTOperationManager sharedManager] performOperationWithOptions:FTRequestOptionGroupRequests operations:^{
        [self GET:@"/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSInteger serverVersion = [responseObject[@"version"] integerValue];
            NSError *error = nil;
            if (serverVersion == self.apiVersion) {
                if (success) success(responseObject);
            } else if (serverVersion < self.apiVersion) {
                error = [NSError errorWithDomain:kFTErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @""}];
            } else if (self.environment == FTEnvironmentProduction) {
                self.environment = FTEnvironmentPreLaunch;
                [ErrorHandler sharedInstance].shouldShowError = NO;
                [[FTAuthenticationManager sharedManager] logout];
                [self validateEnvironmentWithSuccess:success failure:failure];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [ErrorHandler sharedInstance].shouldShowError = YES;
                });
            } else {
                error = [NSError errorWithDomain:kFTErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @""}];
            }
            
            if (error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kFTNotificationAPIOutdated object:nil];
            }
        } failure:failure];
    }];
}

@end
