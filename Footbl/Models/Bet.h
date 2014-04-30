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
@class Wallet;

@interface Bet : _Bet

+ (void)createWithMatch:(Match *)match bid:(NSNumber *)bid result:(MatchResult)result success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
+ (void)updateWithWallet:(Wallet *)wallet success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)updateWithBid:(NSNumber *)bid result:(MatchResult)result success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)deleteWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;

@end
