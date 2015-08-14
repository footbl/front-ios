//
//  FTBMatch.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBModel.h"

@class FTBChampionship;
@class FTBTeam;

typedef NS_ENUM(NSUInteger, FTBMatchResult) {
	FTBMatchResultDraw,
	FTBMatchResultGuest,
	FTBMatchResultHost
};

@interface FTBMatch : FTBModel

@property (nonatomic, copy, readonly) FTBChampionship *championship;
@property (nonatomic, copy, readonly) FTBTeam *guest;
@property (nonatomic, copy, readonly) FTBTeam *host;
@property (nonatomic, copy, readonly) FTBTeam *winner;
@property (nonatomic, assign, readonly) NSUInteger round;
@property (nonatomic, copy, readonly) NSDate *date;
@property (nonatomic, assign, readonly, getter=isFinished) BOOL finished;
@property (nonatomic, assign, readonly) NSTimeInterval elapsed;
@property (nonatomic, assign, readonly) NSUInteger guestResult;
@property (nonatomic, assign, readonly) NSUInteger hostResult;
@property (nonatomic, assign, readonly) NSUInteger guestPot;
@property (nonatomic, assign, readonly) NSUInteger hostPot;
@property (nonatomic, assign, readonly) NSUInteger drawPot;
@property (nonatomic, assign, readonly) NSUInteger jackpot;
@property (nonatomic, assign, readonly) float reward;

+ (NSValueTransformer *)resultJSONTransformer;

@end
