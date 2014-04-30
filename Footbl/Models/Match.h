//
//  Match.h
//  Footbl
//
//  Created by Fernando Saragoça on 3/26/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "_Match.h"

typedef NS_ENUM(NSInteger, MatchResult) {
    MatchResultDraw = 0,
    MatchResultHost = 1,
    MatchResultGuest = 2
};

extern NSString * MatchResultToString(MatchResult result);
extern MatchResult MatchResultFromString(NSString *result);

@class Championship;

@interface Match : _Match

+ (void)updateFromChampionship:(Championship *)championship success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
+ (void)updateBetsFromChampionship:(Championship *)championship success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)updateBetWithBid:(NSNumber *)bid result:(MatchResult)result success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)deleteBetWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;

@end
