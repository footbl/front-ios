//
//  Bet.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/29/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "_Bet.h"
#import "Match.h"

@class Match;
@class User;
@class Wallet;

@interface Bet : _Bet

+ (void)createWithMatch:(Match *)match bid:(NSNumber *)bid result:(MatchResult)result success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
- (void)updateWithBid:(NSNumber *)bid result:(MatchResult)result success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;

- (NSString *)valueString;
- (NSNumber *)toReturn;
- (NSString *)toReturnString;
- (NSNumber *)reward;
- (NSString *)rewardString;

@end
