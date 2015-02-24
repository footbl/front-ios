//
//  Prize.m
//  Footbl
//
//  Created by Fernando Saragoça on 11/21/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "_Prize.h"

typedef NS_ENUM(NSUInteger, PrizeType) {
    PrizeTypeUnknown = 0,
    PrizeTypeDaily = 1,
    PrizeTypeUpdate = 2
};

@interface Prize : _Prize

- (void)markAsReadWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
- (PrizeType)type;

@end
