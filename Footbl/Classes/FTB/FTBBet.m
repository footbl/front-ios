//
//  FTBBet.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBBet.h"
#import "FTBUser.h"
#import "FTBMatch.h"

#import "NSNumber+Formatter.h"

@implementation FTBBet

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	NSDictionary *keyPaths = @{@"user": @"user",
							   @"match": @"match",
							   @"bid": @"bid",
							   @"result": @"result"};
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}

+ (NSValueTransformer *)resultJSONTransformer {
	return [FTBMatch resultJSONTransformer];
}

+ (NSValueTransformer *)userJSONTransformer {
	return [MTLJSONAdapter dictionaryTransformerWithModelClass:[FTBUser class]];
}

+ (NSValueTransformer *)matchJSONTransformer {
	return [MTLJSONAdapter dictionaryTransformerWithModelClass:[FTBMatch class]];
}

- (NSString *)valueString {
	return [self.bid isEqualToNumber:@0] ? @"-" : self.bid.walletStringValue;
}

- (NSNumber *)toReturn {
	switch (self.result) {
		case FTBMatchResultHost:
			return @(self.bid.integerValue * self.match.earningsPerBetForHost.floatValue);
		case FTBMatchResultDraw:
			return @(self.bid.integerValue * self.match.earningsPerBetForDraw.floatValue);
		case FTBMatchResultGuest:
			return @(self.bid.integerValue * self.match.earningsPerBetForGuest.floatValue);
		default:
			return @0;
	}
}

- (NSString *)toReturnString {
	return [self.bid isEqualToNumber:@0] ? @"-" : @(nearbyint(self.toReturn.doubleValue)).walletStringValue;
}

- (NSNumber *)reward {
	if ([self.bid isEqualToNumber:@0] || self.match.status == FTBMatchStatusWaiting) {
		return @0;
	}
	
	if (self.result == self.match.result) {
		return @(self.toReturn.floatValue - self.bid.integerValue);
	} else {
		return @(-self.bid.integerValue);
	}
}

- (NSString *)rewardString {
	if ([self.bid isEqualToNumber:@0] || self.match.status == FTBMatchStatusWaiting) {
		return @"-";
	}
	return @(nearbyint(self.reward.doubleValue)).walletStringValue;
}

- (BOOL)isEqual:(FTBBet *)object {
    if (self.identifier.length > 0) {
        return [super isEqual:object];
    } else {
        return [object isKindOfClass:[FTBBet class]] && [object.match isEqual:self.match];
    }
}

- (NSUInteger)hash {
    if (self.identifier.length > 0) {
        return [super hash];
    } else {
        return self.match.hash;
    }
}

@end
