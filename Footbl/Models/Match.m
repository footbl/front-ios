//
//  Match.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/26/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <TransformerKit/TransformerKit.h>
#import "Bet.h"
#import "Championship.h"
#import "NSNumber+Formatter.h"
#import "Match.h"
#import "Team.h"
#import "User.h"
#import "Wallet.h"

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
@synthesize tempBetResult = _tempBetResult;
@synthesize tempBetValue = _tempBetValue;
@synthesize betBlockKey = _betBlockKey;

#pragma mark - Class Methods

+ (NSString *)resourcePath {
    return @"matches";
}

+ (NSDictionary *)relationshipProperties {
    return @{@"host" : [Team class],
             @"guest" : [Team class]};
}

+ (void)getWithObject:(Championship *)championship success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    NSString *path = [self resourcePathWithObject:championship];
    [[FTOperationManager sharedManager] GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[self class] loadContent:responseObject inManagedObjectContext:[[self class] editableManagedObjectContext] usingCache:championship.matches enumeratingObjectsWithBlock:^(Match *match, NSDictionary *data) {
            match.championship = championship.editableObject;
        } untouchedObjectsBlock:^(NSSet *untouchedObjects) {
            [[self editableManagedObjectContext] deleteObjects:untouchedObjects];
        } completionBlock:success];
    } failure:failure];
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
    
    if (self.managedObjectContext != FootblManagedObjectContext()) {
        [(Match *)[FootblManagedObjectContext() objectWithID:self.objectID] setBetBlockKey:betBlockKey];
    }
}

- (void)setBetSyncing:(BOOL)betSyncing {
    _betSyncing = betSyncing;
    
    if (self.managedObjectContext != FootblManagedObjectContext()) {
        [(Match *)[FootblManagedObjectContext() objectWithID:self.objectID] setBetSyncing:betSyncing];
    }
}

- (void)setBetTemporaryResult:(MatchResult)result value:(NSNumber *)value {
    if (self.managedObjectContext != FootblManagedObjectContext()) {
        [(Match *)[FootblManagedObjectContext() objectWithID:self.objectID] setBetTemporaryResult:result value:value];
    }
    self.tempBetResult = result;
    self.tempBetValue = value;
    
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
    
    self.guest = [Team findOrCreateWithObject:data[@"guest"] inContext:self.managedObjectContext];
    self.host = [Team findOrCreateWithObject:data[@"host"] inContext:self.managedObjectContext];
    
    self.finished = data[@"finished"];
    self.hostScore = data[@"result"][@"host"];
    self.guestScore = data[@"result"][@"guest"];
    self.potDraw = data[@"pot"][@"draw"];
    self.potGuest = data[@"pot"][@"guest"];
    self.potHost = data[@"pot"][@"host"];
    self.round = data[@"round"];
    self.jackpot = data[@"jackpot"];
    
    if ([data[@"elapsed"] isKindOfClass:[NSNumber class]]) {
        self.elapsed = data[@"elapsed"];
    } else {
        self.elapsed = nil;
    }
    
    NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName];
    self.date = [transformer reverseTransformedValue:data[@"date"]];
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
    return self.tempBetValue ? self.tempBetResult : (MatchResult)self.myBet.resultValue;
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
    if (self.myBetValue) {
        jackpot -= self.myBet.valueValue;
        jackpot += self.myBetValue.floatValue;
    }
    return @(jackpot);
}

#pragma mark Wallet

- (NSNumber *)myBetValue {
    if (FBTweakValue(@"Values", @"Match", @"Bet Value", 0, 0, HUGE_VAL)) {
        return @(FBTweakValue(@"Values", @"Match", @"Bet Value", 0, 0, HUGE_VAL));
    }
    
    if (self.tempBetValue) {
        return self.tempBetValue;
    } else {
        return self.myBet.value;
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
    if (self.myBet.resultValue == MatchResultHost) {
        sumOfBets -= self.myBet.valueValue;
    }
    if (self.myBetResult == MatchResultHost) {
        sumOfBets += self.myBetValue.floatValue;
    }
    return @(MAX(1, self.localJackpot.floatValue / MAX(1, sumOfBets)));
}

- (NSNumber *)earningsPerBetForDraw {
    if (FBTweakValue(@"Values", @"Match", @"Pot Draw", 0, 0, HUGE_VAL)) {
        return @(MAX(1, (FBTweakValue(@"Values", @"Match", @"Pot Draw", 0, 0, HUGE_VAL))));
    }
    
    float sumOfBets = self.potDrawValue;
    if (self.myBet.resultValue == MatchResultDraw) {
        sumOfBets -= self.myBet.valueValue;
    }
    if (self.myBetResult == MatchResultDraw) {
        sumOfBets += self.myBetValue.floatValue;
    }
    return @(MAX(1, self.localJackpot.floatValue / MAX(1, sumOfBets)));
}

- (NSNumber *)earningsPerBetForGuest {
    if (FBTweakValue(@"Values", @"Match", @"Pot Guest", 0, 0, HUGE_VAL)) {
        return @(MAX(1, (FBTweakValue(@"Values", @"Match", @"Pot Guest", 0, 0, HUGE_VAL))));
    }
    
    float sumOfBets = self.potGuestValue;
    if (self.myBet.resultValue == MatchResultGuest) {
        sumOfBets -= self.myBet.valueValue;
    }
    if (self.myBetResult == MatchResultGuest) {
        sumOfBets += self.myBetValue.floatValue;
    }
    return @(MAX(1, self.localJackpot.floatValue / MAX(1, sumOfBets)));
}

@end
