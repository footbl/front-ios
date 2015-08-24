//
//  FTOperationManager.h
//  Footbl
//
//  Created by Fernando Saragoça on 8/7/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "FTRequestSerializer.h"
#import "FTBConstants.h"

typedef NS_ENUM(NSUInteger, FTEnvironment) {
    FTEnvironmentDevelopment = 1,
    FTEnvironmentPreLaunch = 2,
    FTEnvironmentProduction = 3
};

typedef void (^FTOperationResponseBlock)(id response, NSError *error);
typedef void (^FTOperationCompletionBlock)(id response);
typedef void (^FTOperationErrorBlock)(AFHTTPRequestOperation *operation, NSError *error);

@interface FTOperationManager : AFHTTPRequestOperationManager

@property (assign, nonatomic) FTEnvironment environment;
@property (copy, nonatomic, readonly) NSString *signatureKey;
@property (assign, nonatomic, readonly) NSUInteger responseLimit;
@property (assign, nonatomic, readonly) NSUInteger apiVersion;

+ (instancetype)sharedManager;
- (void)performOperationWithOptions:(FTRequestOptions)options operations:(void (^)())operations;
- (void)validateEnvironmentWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;

@end
