//
//  CreditRequest.h
//  Footbl
//
//  Created by Fernando Saragoça on 8/14/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "_CreditRequest.h"

@interface CreditRequest : _CreditRequest

+ (void)createWithIds:(NSArray *)ids success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
+ (void)getRequestsWithObject:(FTModel *)object success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
+ (void)payRequests:(NSArray *)requests success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;

@end
