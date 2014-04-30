//
//  Match.h
//  Footbl
//
//  Created by Fernando Saragoça on 3/26/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "_Match.h"

typedef NS_ENUM(NSInteger, MatchResult) {
    MatchResultDraw = 1,
    MatchResultHost = 2,
    MatchResultGuest = 3
};

extern NSString * MatchResultToString(MatchResult result);
extern MatchResult MatchResultFromString(NSString *result);

@class Championship;

@interface Match : _Match

+ (void)updateFromChampionship:(Championship *)championship success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;

@end
