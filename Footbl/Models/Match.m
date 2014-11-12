//
//  Match.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/26/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <TransformerKit/TTTDateTransformers.h>
#import "Bet.h"
#import "Championship.h"
#import "NSNumber+Formatter.h"
#import "Match.h"
#import "Team.h"
#import "User.h"

extern NSString * MatchResultToString(MatchResult result) {
    switch (result) {
        case MatchResultDraw:
            return @"draw";
        case MatchResultGuest:
            return @"guest";
        case MatchResultHost:
            return @"host";
    }
}

extern MatchResult MatchResultFromString(NSString *result) {
    if ([result.lowercaseString isEqualToString:@"guest"]) {
        return MatchResultGuest;
    } else if ([result.lowercaseString isEqualToString:@"host"]) {
        return MatchResultHost;
    } else {
        return MatchResultDraw;
    }
}

@interface Match ()

@end

#pragma mark Match

@implementation Match

@synthesize betSyncing = _betSyncing;
@synthesize betBlockKey = _betBlockKey;

#pragma mark - Class Methods

+ (NSString *)resourcePath {
    return @"matches";
}

+ (NSArray *)enabledProperties {
    return [[super enabledProperties] arrayByAddingObjectsFromArray:@[@"elapsed", @"finished", @"jackpot", @"round"]];
}

+ (void)getWithObject:(Championship *)championship success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    NSString *path = [self resourcePathWithObject:championship];
    [[FTOperationManager sharedManager] GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[self class] loadContent:responseObject inManagedObjectContext:[FTCoreDataStore privateQueueContext] usingCache:nil enumeratingObjectsWithBlock:^(Match *match, NSDictionary *data) {
            match.championship = championship.editableObject;
        } untouchedObjectsBlock:^(NSSet *untouchedObjects) {
            [[FTCoreDataStore privateQueueContext] deleteObjects:[untouchedObjects filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"championship = %@", championship]]];
        } completionBlock:success];
    } failure:failure];
}

+ (NSMutableDictionary *)temporaryBetsDictionary {
    static NSMutableDictionary *temporaryBetsDictionary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        temporaryBetsDictionary = [NSMutableDictionary new];
    });
    return temporaryBetsDictionary;
}

#pragma mark - Instance Methods

- (Bet *)myBet {
    return [self betForUser:[User currentUser]];
}

- (Bet *)betForUser:(User *)user {
    return [self.bets filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"user.rid = %@", user.rid]].anyObject;
}

- (void)setBetBlockKey:(NSUInteger)betBlockKey {
    _betBlockKey = betBlockKey;
    
    if (self.managedObjectContext != [FTCoreDataStore mainQueueContext]) {
        [(Match *)[[FTCoreDataStore mainQueueContext] objectWithID:[self objectID]] setBetBlockKey:betBlockKey];
    }
}

- (void)setBetSyncing:(BOOL)betSyncing {
    _betSyncing = betSyncing;
    
    if (self.managedObjectContext != [FTCoreDataStore mainQueueContext]) {
        [(Match *)[[FTCoreDataStore mainQueueContext] objectWithID:[self objectID]] setBetSyncing:betSyncing];
    }
}

- (void)setBetTemporaryResult:(MatchResult)result value:(NSNumber *)value {
    if (value) {
        [Match temporaryBetsDictionary][self.rid] = @{@"result" : @(result), @"value" : value};
    } else {
        [[Match temporaryBetsDictionary] removeObjectForKey:self.rid];
    }
    
    if (value && ![[User currentUser].pendingMatchesToSyncBet containsObject:self]) {
        [[User currentUser].pendingMatchesToSyncBet addObject:self];
    } else if (!value) {
        [[User currentUser].pendingMatchesToSyncBet removeObject:self];
    }
}

- (NSString *)resourcePath {
    return [NSString stringWithFormat:@"%@/matches/%@", self.championship.resourcePath, self.slug];
}

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    if ([data[@"bet"] isKindOfClass:[NSDictionary class]]) {
        Bet *bet = [Bet findOrCreateWithObject:data[@"bet"] inContext:self.managedObjectContext];
        bet.match = self;
        bet.user = [User currentUser].editableObject;
    } else if (data[@"bet"] && self.myBet) {
        [[FTCoreDataStore privateQueueContext] deleteObject:self.myBet];
    }
    self.guest = [Team findOrCreateWithObject:data[@"guest"] inContext:self.managedObjectContext];
    self.host = [Team findOrCreateWithObject:data[@"host"] inContext:self.managedObjectContext];
    
    self.hostScore = data[@"result"][@"host"];
    self.guestScore = data[@"result"][@"guest"];
    self.potDraw = data[@"pot"][@"draw"];
    self.potGuest = data[@"pot"][@"guest"];
    self.potHost = data[@"pot"][@"host"];
}

- (NSString *)dateString {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    formatter.AMSymbol = @"am";
    formatter.PMSymbol = @"pm";
    formatter.dateFormat = [@"EEEE, " stringByAppendingString:formatter.dateFormat];
    formatter.dateFormat = [formatter.dateFormat stringByReplacingOccurrencesOfString:@", y" withString:@""];
    formatter.dateFormat = [formatter.dateFormat stringByReplacingOccurrencesOfString:@"/y" withString:@""];
    formatter.dateFormat = [formatter.dateFormat stringByReplacingOccurrencesOfString:@"y" withString:@""];
    return [formatter stringFromDate:self.date];
}

- (MatchResult)myBetResult {
    return [Match temporaryBetsDictionary][self.rid] ? [[Match temporaryBetsDictionary][self.rid][@"result"] integerValue] : self.myBet.resultValue;
}

- (MatchResult)result {
    if (self.hostScoreValue == self.guestScoreValue) {
        return MatchResultDraw;
    } else if (self.hostScoreValue > self.guestScoreValue) {
        return MatchResultHost;
    } else {
        return MatchResultGuest;
    }
}

- (MatchStatus)status {
    if (self.elapsed) {
        return MatchStatusLive;
    } else if (self.finishedValue) {
        return MatchStatusFinished;
    } else {
        return MatchStatusWaiting;
    }
}

- (NSString *)myBetValueString {
    return self.myBetValue.floatValue == 0 ? @"-" : @(self.myBetValue.integerValue).walletStringValue;
}

- (NSNumber *)localJackpot {
    if (FBTweakValue(@"Values", @"Match", @"Jackpot", 0, 0, HUGE_VAL)) {
        return @(FBTweakValue(@"Values", @"Match", @"Jackpot", 0, 0, HUGE_VAL));
    }
    
    float jackpot = self.jackpotValue;
    if ([Match temporaryBetsDictionary][self.slug]) {
        jackpot -= self.myBet.bidValue;
        jackpot += [[Match temporaryBetsDictionary][self.slug][@"value"] integerValue];
    }
    return @(jackpot);
}

#pragma mark Wallet

- (NSNumber *)myBetValue {
    if (FBTweakValue(@"Values", @"Match", @"Bet Value", 0, 0, HUGE_VAL)) {
        return @(FBTweakValue(@"Values", @"Match", @"Bet Value", 0, 0, HUGE_VAL));
    }
    
    if ([Match temporaryBetsDictionary][self.rid]) {
        return [Match temporaryBetsDictionary][self.rid][@"value"];
    } else {
        return self.myBet.bid;
    }
}

- (NSNumber *)myBetReturn {
    switch (self.myBetResult) {
        case MatchResultHost:
            return @(self.myBetValue.floatValue * self.earningsPerBetForHost.floatValue);
        case MatchResultDraw:
            return @(self.myBetValue.floatValue * self.earningsPerBetForDraw.floatValue);
        case MatchResultGuest:
            return @(self.myBetValue.floatValue * self.earningsPerBetForGuest.floatValue);
        default:
            return @0;
    }
}

- (NSString *)myBetReturnString {
    return self.myBetValue.floatValue == 0 ? @"-" : @(nearbyintf(self.myBetReturn.floatValue)).walletStringValue;
}

- (NSNumber *)myBetProfit {
    if ((!self.myBetValue || self.status == MatchStatusWaiting) && !FBTweakValue(@"Values", @"Match", @"Bet Profit", NO)) {
        return @0;
    }
    
    if (self.result == self.myBetResult) {
        return @(self.myBetReturn.floatValue - self.myBetValue.floatValue);
    } else {
        return @(-self.myBetValue.floatValue);
    }
}

- (NSString *)myBetProfitString {
    if ((!self.myBetValue || self.status == MatchStatusWaiting) && !FBTweakValue(@"Values", @"Match", @"Bet Profit", NO)) {
        return @"-";
    }
    
    return @(nearbyintf(self.myBetProfit.floatValue)).walletStringValue;
}

#pragma mark Earnings per bet

- (NSNumber *)earningsPerBetForHost {
    if (FBTweakValue(@"Values", @"Match", @"Pot Host", 0, 0, HUGE_VAL)) {
        return @(MAX(1, (FBTweakValue(@"Values", @"Match", @"Pot Host", 0, 0, HUGE_VAL))));
    }
    
    float sumOfBets = self.potHostValue;
    if ([Match temporaryBetsDictionary][self.rid]) {
        if (self.myBet.resultValue == MatchResultHost) {
            sumOfBets -= self.myBet.bidValue;
        }
        if ([[Match temporaryBetsDictionary][self.rid][@"result"] integerValue] == MatchResultHost) {
            sumOfBets += [[Match temporaryBetsDictionary][self.rid][@"value"] integerValue];
        }
    }
    return @(MAX(1, self.localJackpot.floatValue / MAX(1, sumOfBets)));
}

- (NSNumber *)earningsPerBetForDraw {
    if (FBTweakValue(@"Values", @"Match", @"Pot Draw", 0, 0, HUGE_VAL)) {
        return @(MAX(1, (FBTweakValue(@"Values", @"Match", @"Pot Draw", 0, 0, HUGE_VAL))));
    }
    
    float sumOfBets = self.potDrawValue;
    if ([Match temporaryBetsDictionary][self.rid]) {
        if (self.myBet.resultValue == MatchResultDraw) {
            sumOfBets -= self.myBet.bidValue;
        }
        if ([[Match temporaryBetsDictionary][self.rid][@"result"] integerValue] == MatchResultDraw) {
            sumOfBets += [[Match temporaryBetsDictionary][self.rid][@"value"] integerValue];
        }
    }
    return @(MAX(1, self.localJackpot.floatValue / MAX(1, sumOfBets)));
}

- (NSNumber *)earningsPerBetForGuest {
    if (FBTweakValue(@"Values", @"Match", @"Pot Guest", 0, 0, HUGE_VAL)) {
        return @(MAX(1, (FBTweakValue(@"Values", @"Match", @"Pot Guest", 0, 0, HUGE_VAL))));
    }
    
    float sumOfBets = self.potGuestValue;
    if ([Match temporaryBetsDictionary][self.rid]) {
        if (self.myBet.resultValue == MatchResultGuest) {
            sumOfBets -= self.myBet.bidValue;
        }
        if ([[Match temporaryBetsDictionary][self.rid][@"result"] integerValue] == MatchResultGuest) {
            sumOfBets += [[Match temporaryBetsDictionary][self.rid][@"value"] integerValue];
        }
    }
    return @(MAX(1, self.localJackpot.floatValue / MAX(1, sumOfBets)));
}

@end
