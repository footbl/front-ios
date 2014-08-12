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

typedef NS_ENUM(NSInteger, MatchStatus) {
    MatchStatusWaiting = 0,
    MatchStatusLive = 1,
    MatchStatusFinished = 2
};

extern NSString * MatchResultToString(MatchResult result);
extern MatchResult MatchResultFromString(NSString *result);

@class Bet;
@class Championship;
@class User;

@interface Match : _Match

@property (assign, nonatomic, getter = isBetSyncing) BOOL betSyncing;
@property (strong, nonatomic) NSNumber *tempBetValue;
@property (assign, nonatomic) MatchResult tempBetResult;
@property (assign, nonatomic) NSUInteger betBlockKey;

- (void)setBetTemporaryResult:(MatchResult)result value:(NSNumber *)value;
- (Bet *)myBet;
- (Bet *)betForUser:(User *)user;

- (MatchResult)result;
- (MatchStatus)status;

- (MatchResult)myBetResult;
- (NSNumber *)localJackpot;

- (NSString *)dateString;

// Earnings
- (NSNumber *)earningsPerBetForHost;
- (NSNumber *)earningsPerBetForDraw;
- (NSNumber *)earningsPerBetForGuest;

// Wallet
- (NSNumber *)myBetValue;
- (NSString *)myBetValueString;

- (NSNumber *)myBetReturn;
- (NSString *)myBetReturnString;

- (NSNumber *)myBetProfit;
- (NSString *)myBetProfitString;

@end
