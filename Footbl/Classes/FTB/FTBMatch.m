//
//  FTBMatch.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBMatch.h"
#import "FTBBet.h"
#import "FTBClient.h"
#import "FTBTeam.h"
#import "FTBUser.h"
#import "NSNumber+Formatter.h"

@implementation FTBMatch

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
							   @"reward": @"reward",
                               @"result": @"winner"};
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}

+ (NSValueTransformer *)resultJSONTransformer {
	NSDictionary *dictionary = @{@"guest": @(FTBMatchResultGuest),
								 @"host": @(FTBMatchResultHost),
								 @"draw": @(FTBMatchResultDraw)};
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:dictionary defaultValue:@(FTBMatchResultUnknown) reverseDefaultValue:[NSNull null]];
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

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self) {
        // This is a hack to fix possible crawler issues (i.e. finished matches with finished == NO)
        if (!self.isFinished && [self.date timeIntervalSinceNow] < - 3 * 60 * 60) {
            self.finished = YES;
        }
    }
    return self;
}

- (FTBTeam *)winner {
    switch (self.result) {
        case FTBMatchResultGuest:
            return self.guest;
        case FTBMatchResultHost:
            return self.host;
        default:
            return nil;
    }
}

- (FTBBet *)myBet {
    return [[FTBUser currentUser] betForMatch:self];
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

- (NSString *)dateString {
	return [self.class.dateFormatter stringFromDate:self.date];
}

- (NSNumber *)earningsPerBetForHost {
	float sumOfBets = self.hostPot.floatValue;
    FTBBet *bet = self.myBet;
	if (bet.result == FTBMatchResultHost) {
        sumOfBets -= bet.bid.integerValue;
	}
	return @(MAX(1, self.jackpot.floatValue / MAX(1, sumOfBets)));
}

- (NSNumber *)earningsPerBetForDraw {
    return @(MAX(1, self.jackpot.floatValue / MAX(1, self.drawPot.floatValue)));
}

- (NSNumber *)earningsPerBetForGuest {
	return @(MAX(1, self.jackpot.floatValue / MAX(1, self.guestPot.floatValue)));
}

- (NSString *)myBetValueString {
	return self.myBet.bid.integerValue == 0 ? @"-" : self.myBet.bid.walletStringValue;
}

- (NSNumber *)myBetReturn {
	switch (self.myBet.result) {
		case FTBMatchResultHost:
			return @(self.myBet.bid.floatValue * self.earningsPerBetForHost.floatValue);
		case FTBMatchResultDraw:
			return @(self.myBet.bid.floatValue * self.earningsPerBetForDraw.floatValue);
		case FTBMatchResultGuest:
			return @(self.myBet.bid.floatValue * self.earningsPerBetForGuest.floatValue);
		default:
			return @0;
	}
}

- (NSString *)myBetReturnString {
	return self.myBet.bid.integerValue == 0 ? @"-" : @(nearbyint(self.myBetReturn.doubleValue)).walletStringValue;
}

- (NSNumber *)myBetProfit {
	if (!self.myBet.bid || self.status == FTBMatchStatusWaiting) {
		return @0;
	}
	
	if (self.result == self.myBet.result) {
		return @(self.myBetReturn.floatValue - self.myBet.bid.floatValue);
	} else {
		return @(-self.myBet.bid.floatValue);
	}
}

- (NSString *)myBetProfitString {
	if (!self.myBet.bid || self.status == FTBMatchStatusWaiting) {
		return @"-";
	}
	
	return @(nearbyint(self.myBetProfit.doubleValue)).walletStringValue;
}

- (BOOL)isBetSyncing {
    for (NSURLSessionDataTask *task in [[FTBClient client] tasks]) {
        if (self.identifier && [task.originalRequest.URL.path containsString:self.identifier]) {
            return YES;
        } else if (self.myBet.identifier && [task.originalRequest.URL.path containsString:self.myBet.identifier]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)updatePotByAddingBet:(FTBBet *)bet {
    switch (bet.result) {
        case FTBMatchResultDraw:
            self.drawPot = @(self.drawPot.integerValue + bet.bid.integerValue);
            break;
        case FTBMatchResultHost:
            self.hostPot = @(self.hostPot.integerValue + bet.bid.integerValue);
            break;
        case FTBMatchResultGuest:
            self.guestPot = @(self.guestPot.integerValue + bet.bid.integerValue);
            break;
        default:
            break;
    }
}

- (void)updatePotByRemovingBet:(FTBBet *)bet {
    switch (bet.result) {
        case FTBMatchResultDraw:
            self.drawPot = @(self.drawPot.integerValue - bet.bid.integerValue);
            break;
        case FTBMatchResultHost:
            self.hostPot = @(self.hostPot.integerValue - bet.bid.integerValue);
            break;
        case FTBMatchResultGuest:
            self.guestPot = @(self.guestPot.integerValue - bet.bid.integerValue);
            break;
        default:
            break;
    }
}

@end
