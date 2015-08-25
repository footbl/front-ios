//
//  FTBMatch.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBMatch.h"
#import "FTBTeam.h"

@implementation FTBMatch

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	NSDictionary *keyPaths = @{@"championship": @"championship",
							   @"guest": @"guest",
							   @"host": @"host",
							   @"round": @"round",
							   @"date": @"date",
							   @"finished": @"finished",
							   @"elapsed": @"elapsed",
							   @"guestResult": @"result.guest",
							   @"hostResult": @"result.host",
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

- (FTBTeam *)winner {
	if ([self.guestResult compare:self.hostResult] == NSOrderedDescending) return self.guest;
	if ([self.guestResult compare:self.hostResult] == NSOrderedAscending) return self.host;
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

- (FTBBet *)myBet {
	// TODO: Implement this method
	return nil;
}

- (NSNumber *)localJackpot {
	return @0;
}

- (NSString *)dateString {
	return @"Date";
}

- (NSNumber *)earningsPerBetForHost {
	return @0;
}

- (NSNumber *)earningsPerBetForDraw {
	return @0;
}

- (NSNumber *)earningsPerBetForGuest {
	return @0;
}

- (NSNumber *)myBetValue {
	return @0;
}

- (NSString *)myBetValueString {
	return @"0";
}

- (NSNumber *)myBetReturn {
	return @0;
}

- (NSString *)myBetReturnString {
	return @"0";
}

- (NSNumber *)myBetProfit {
	return @0;
}

- (NSString *)myBetProfitString {
	return @"0";
}

@end
