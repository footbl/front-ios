//
//  FTBMatch.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBMatch.h"
#import "FTBTeam.h"
#import "FTBBet.h"
#import "FTBUser.h"

#import "NSNumber+Formatter.h"

@implementation FTBMatch

+ (NSMutableDictionary *)temporaryBetsDictionary {
	static NSMutableDictionary *temporaryBetsDictionary;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		temporaryBetsDictionary = [NSMutableDictionary new];
	});
	return temporaryBetsDictionary;
}

+ (NSDateFormatter *)dateFormatter {
	static NSDateFormatter *dateFormatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.dateStyle = NSDateFormatterShortStyle;
		dateFormatter.timeStyle = NSDateFormatterShortStyle;
		dateFormatter.AMSymbol = @"am";
		dateFormatter.PMSymbol = @"pm";
		dateFormatter.dateFormat = [@"EEEE, " stringByAppendingString:dateFormatter.dateFormat];
		dateFormatter.dateFormat = [dateFormatter.dateFormat stringByReplacingOccurrencesOfString:@", y" withString:@""];
		dateFormatter.dateFormat = [dateFormatter.dateFormat stringByReplacingOccurrencesOfString:@"/y" withString:@""];
		dateFormatter.dateFormat = [dateFormatter.dateFormat stringByReplacingOccurrencesOfString:@"y" withString:@""];
	});
	return dateFormatter;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	NSDictionary *keyPaths = @{@"championship": @"championship",
							   @"guest": @"guest",
							   @"host": @"host",
							   @"round": @"round",
							   @"date": @"date",
							   @"finished": @"finished",
							   @"elapsed": @"elapsed",
							   @"guestScore": @"result.guest",
							   @"hostScore": @"result.host",
							   @"guestPot": @"pot.guest",
							   @"hostPot": @"pot.host",
							   @"drawPot": @"pot.draw",
							   @"jackpot": @"jackpot",
							   @"reward": @"reward"};
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}

+ (NSValueTransformer *)resultJSONTransformer {
	NSDictionary *dictionary = @{@"guest": @(FTBMatchResultGuest),
								 @"host": @(FTBMatchResultHost),
								 @"draw": @(FTBMatchResultDraw)};
	return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:dictionary];
}

+ (NSValueTransformer *)dateJSONTransformer {
	return [super dateJSONTransformer];
}

+ (NSValueTransformer *)guestJSONTransformer {
	return [MTLJSONAdapter dictionaryTransformerWithModelClass:[FTBTeam class]];
}

+ (NSValueTransformer *)hostJSONTransformer {
	return [MTLJSONAdapter dictionaryTransformerWithModelClass:[FTBTeam class]];
}

+ (NSValueTransformer *)elapsedJSONTransformer {
	return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
		return value ?: @0;
	}];
}

- (FTBTeam *)winner {
	if ([self.guestScore compare:self.hostScore] == NSOrderedDescending) return self.guest;
	if ([self.guestScore compare:self.hostScore] == NSOrderedAscending) return self.host;
	return nil;
}

- (FTBMatchStatus)status {
	if (self.elapsed) {
		return FTBMatchStatusLive;
	} else if (self.isFinished) {
		return FTBMatchStatusFinished;
	} else {
		return FTBMatchStatusWaiting;
	}
}

- (FTBMatchResult)result {
	if ([self.winner isEqual:self.host]) {
		return FTBMatchResultHost;
	} else if ([self.winner isEqual:self.guest]) {
		return FTBMatchResultGuest;
	} else {
		return FTBMatchResultDraw;
	}
}

- (FTBMatchResult)myBetResult {
	NSDictionary *result = [FTBMatch temporaryBetsDictionary][self.identifier];
	return result ? [result[@"result"] integerValue] : self.myBet.result;
}

- (NSNumber *)localJackpot {
	if (FBTweakValue(@"Values", @"Match", @"Jackpot", 0, 0, HUGE_VAL)) {
		return @(FBTweakValue(@"Values", @"Match", @"Jackpot", 0, 0, HUGE_VAL));
	}
	
	float jackpot = self.jackpot.floatValue;
	NSDictionary *result = [FTBMatch temporaryBetsDictionary][self.identifier];
	if (result) {
		jackpot -= self.myBet.bid.integerValue;
		jackpot += [result[@"value"] integerValue];
	}
	return @(jackpot);
}

- (NSString *)dateString {
	return [[FTBMatch dateFormatter] stringFromDate:self.date];
}

- (NSNumber *)earningsPerBetForHost {
	if (FBTweakValue(@"Values", @"Match", @"Pot Host", 0, 0, HUGE_VAL)) {
		return @(MAX(1, (FBTweakValue(@"Values", @"Match", @"Pot Host", 0, 0, HUGE_VAL))));
	}
	
	float sumOfBets = self.hostPot.floatValue;
	NSDictionary *result = [FTBMatch temporaryBetsDictionary][self.identifier];
	if (result) {
		if (self.myBet.result == FTBMatchResultHost) {
			sumOfBets -= self.myBet.bid.integerValue;
		}
		if ([result[@"result"] integerValue] == FTBMatchResultHost) {
			sumOfBets += [result[@"value"] integerValue];
		}
	}
	return @(MAX(1, self.localJackpot.floatValue / MAX(1, sumOfBets)));
}

- (NSNumber *)earningsPerBetForDraw {
	if (FBTweakValue(@"Values", @"Match", @"Pot Draw", 0, 0, HUGE_VAL)) {
		return @(MAX(1, (FBTweakValue(@"Values", @"Match", @"Pot Draw", 0, 0, HUGE_VAL))));
	}
	
	float sumOfBets = self.drawPot.floatValue;
	NSDictionary *result = [FTBMatch temporaryBetsDictionary][self.identifier];
	if (result) {
		if (self.myBet.result == FTBMatchResultDraw) {
			sumOfBets -= self.myBet.bid.integerValue;
		}
		if ([result[@"result"] integerValue] == FTBMatchResultDraw) {
			sumOfBets += [result[@"value"] integerValue];
		}
	}
	return @(MAX(1, self.localJackpot.floatValue / MAX(1, sumOfBets)));
}

- (NSNumber *)earningsPerBetForGuest {
	if (FBTweakValue(@"Values", @"Match", @"Pot Guest", 0, 0, HUGE_VAL)) {
		return @(MAX(1, (FBTweakValue(@"Values", @"Match", @"Pot Guest", 0, 0, HUGE_VAL))));
	}
	
	float sumOfBets = self.guestPot.floatValue;
	NSDictionary *result = [FTBMatch temporaryBetsDictionary][self.identifier];
	if (result) {
		if (self.myBet.result == FTBMatchResultGuest) {
			sumOfBets -= self.myBet.bid.integerValue;
		}
		if ([result[@"result"] integerValue] == FTBMatchResultGuest) {
			sumOfBets += [result[@"value"] integerValue];
		}
	}
	return @(MAX(1, self.localJackpot.floatValue / MAX(1, sumOfBets)));
}

- (NSNumber *)myBetValue {
	if (FBTweakValue(@"Values", @"Match", @"Bet Value", 0, 0, HUGE_VAL)) {
		return @(FBTweakValue(@"Values", @"Match", @"Bet Value", 0, 0, HUGE_VAL));
	}
	
	NSDictionary *result = [FTBMatch temporaryBetsDictionary][self.identifier];
	if (result) {
		return result[@"value"];
	} else {
		return self.myBet.bid;
	}
}

- (NSString *)myBetValueString {
	return [self.myBetValue isEqualToNumber:@0] ? @"-" : self.myBetValue.walletStringValue;
}

- (NSNumber *)myBetReturn {
	switch (self.myBetResult) {
		case FTBMatchResultHost:
			return @(self.myBetValue.floatValue * self.earningsPerBetForHost.floatValue);
		case FTBMatchResultDraw:
			return @(self.myBetValue.floatValue * self.earningsPerBetForDraw.floatValue);
		case FTBMatchResultGuest:
			return @(self.myBetValue.floatValue * self.earningsPerBetForGuest.floatValue);
		default:
			return @0;
	}
}

- (NSString *)myBetReturnString {
	return [self.myBetValue isEqualToNumber:@0] ? @"-" : @(nearbyint(self.myBetReturn.doubleValue)).walletStringValue;
}

- (NSNumber *)myBetProfit {
	if ((!self.myBetValue || self.status == FTBMatchStatusWaiting) && !FBTweakValue(@"Values", @"Match", @"Bet Profit", NO)) {
		return @0;
	}
	
	if (self.result == self.myBetResult) {
		return @(self.myBetReturn.floatValue - self.myBetValue.floatValue);
	} else {
		return @(-self.myBetValue.floatValue);
	}
}

- (NSString *)myBetProfitString {
	if ((!self.myBetValue || self.status == FTBMatchStatusWaiting) && !FBTweakValue(@"Values", @"Match", @"Bet Profit", NO)) {
		return @"-";
	}
	
	return @(nearbyint(self.myBetProfit.doubleValue)).walletStringValue;
}

- (void)setBetTemporaryResult:(FTBMatchResult)result value:(NSNumber *)value {
	if (value) {
		[FTBMatch temporaryBetsDictionary][self.identifier] = @{@"result" : @(result), @"value" : value};
	} else {
		[[FTBMatch temporaryBetsDictionary] removeObjectForKey:self.identifier];
	}
	
	FTBUser *user = [FTBUser currentUser];
	if (value && ![user.pendingMatchesToSyncBet containsObject:self]) {
		[user.pendingMatchesToSyncBet addObject:self];
	} else if (!value) {
		[user.pendingMatchesToSyncBet removeObject:self];
	}
}

- (BOOL)isBetSyncing {
    FTBUser *user = [FTBUser currentUser];
    return [user.pendingMatchesToSyncBet containsObject:self];
}

@end
