//
//  FTBMatch.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBModel.h"
#import "FTBConstants.h"

@class FTBChampionship;
@class FTBTeam;
@class FTBBet;

@interface FTBMatch : FTBModel

@property (nonatomic, copy, readonly) FTBChampionship *championship;
@property (nonatomic, copy, readonly) FTBTeam *guest;
@property (nonatomic, copy, readonly) FTBTeam *host;
@property (nonatomic, copy, readonly) FTBTeam *winner;
@property (nonatomic, copy, readonly) NSNumber *round;
@property (nonatomic, copy, readonly) NSDate *date;
@property (nonatomic, assign, readonly, getter=isFinished) BOOL finished;
@property (nonatomic, assign, readonly) NSTimeInterval elapsed;
@property (nonatomic, copy, readonly) NSNumber *guestScore;
@property (nonatomic, copy, readonly) NSNumber *hostScore;
@property (nonatomic, copy, readonly) NSNumber *guestPot;
@property (nonatomic, copy, readonly) NSNumber *hostPot;
@property (nonatomic, copy, readonly) NSNumber *drawPot;
@property (nonatomic, copy, readonly) NSNumber *jackpot;
@property (nonatomic, copy, readonly) NSNumber *reward;

+ (NSValueTransformer *)resultJSONTransformer;

// TODO: Set this property to YES in every bet request, then set it to NO after the response
@property (assign, nonatomic, getter = isBetSyncing) BOOL betSyncing;
- (FTBMatchStatus)status;
- (FTBBet *)myBet;
- (FTBMatchResult)result;
- (FTBMatchResult)myBetResult;
- (NSNumber *)localJackpot;
- (NSString *)dateString;
- (NSNumber *)earningsPerBetForHost;
- (NSNumber *)earningsPerBetForDraw;
- (NSNumber *)earningsPerBetForGuest;
- (NSNumber *)myBetValue;
- (NSString *)myBetValueString;
- (NSNumber *)myBetReturn;
- (NSString *)myBetReturnString;
- (NSNumber *)myBetProfit;
- (NSString *)myBetProfitString;

@end
