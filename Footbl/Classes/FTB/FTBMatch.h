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

@property (nonatomic, copy) FTBChampionship *championship;
@property (nonatomic, copy) FTBTeam *guest;
@property (nonatomic, copy) FTBTeam *host;
@property (nonatomic, copy) FTBTeam *winner;
@property (nonatomic, copy) NSNumber *round;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, assign, getter=isFinished) BOOL finished;
@property (nonatomic, assign) NSTimeInterval elapsed;
@property (nonatomic, copy) NSNumber *guestScore;
@property (nonatomic, copy) NSNumber *hostScore;
@property (nonatomic, copy) NSNumber *guestPot;
@property (nonatomic, copy) NSNumber *hostPot;
@property (nonatomic, copy) NSNumber *drawPot;
@property (nonatomic, copy) NSNumber *jackpot;
@property (nonatomic, copy) NSNumber *reward;

+ (NSValueTransformer *)resultJSONTransformer;

- (FTBBet *)myBet;
- (FTBMatchStatus)status;
- (FTBMatchResult)result;
- (NSString *)dateString;
- (NSNumber *)earningsPerBetForHost;
- (NSNumber *)earningsPerBetForDraw;
- (NSNumber *)earningsPerBetForGuest;
- (NSString *)myBetValueString;
- (NSNumber *)myBetReturn;
- (NSString *)myBetReturnString;
- (NSNumber *)myBetProfit;
- (NSString *)myBetProfitString;
- (BOOL)isBetSyncing;

@end
