//
//  FTBUser.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBUser.h"
#import "FTBChampionship.h"
#import "FTBSeason.h"
#import "FTBMatch.h"
#import "FTBBet.h"
#import "FTAuthenticationManager.h"
#import "NSNumber+Formatter.h"

#import <TransformerKit/TTTDateTransformers.h>

@implementation FTBUserSeasonEvolution

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	NSDictionary *keyPaths = @{@"funds": @"funds"};
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}

@end

@implementation FTBUserSeason

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	NSDictionary *keyPaths = @{@"season": @"season",
							   @"rankings": @"rankings",
							   @"stake": @"stake",
							   @"funds": @"funds",
							   @"evolution": @"evolution"};
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}

+ (NSValueTransformer *)seasonJSONTransformer {
	return [MTLJSONAdapter dictionaryTransformerWithModelClass:[FTBSeason class]];
}

+ (NSValueTransformer *)evolutionJSONTransformer {
	return [MTLJSONAdapter arrayTransformerWithModelClass:[FTBUserSeasonEvolution class]];
}

@end

@implementation FTBUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	NSDictionary *keyPaths = @{@"email": @"email",
							   @"username": @"username",
							   @"facebookId": @"facebookId",
							   @"password": @"password",
							   @"name": @"name",
							   @"about": @"about",
							   @"verified": @"verified",
							   @"featured": @"featured",
							   @"pictureURL": @"picture",
							   @"apnsToken": @"apnsToken",
							   @"active": @"active",
							   @"country": @"country",
							   @"entries": @"entries",
							   @"seasons": @"seasons",
							   @"starred": @"starred"};
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}

+ (NSValueTransformer *)entriesJSONTransformer {
	return [MTLJSONAdapter arrayTransformerWithModelClass:[FTBChampionship class]];
}

+ (NSValueTransformer *)seasonsJSONTransformer {
	return [MTLJSONAdapter arrayTransformerWithModelClass:[FTBUserSeason class]];
}

+ (NSValueTransformer *)starredJSONTransformer {
	return [MTLJSONAdapter arrayTransformerWithModelClass:[FTBUser class]];
}

#pragma mark - Helpers

+ (instancetype)currentUser {
	return [[FTAuthenticationManager sharedManager] user];
}

- (NSSet *)bets {
	return nil;
}

- (NSSet *)activeBets {
	return [self.bets filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"bid > 0 AND match.finished = NO AND match != nil"]];
}

- (BOOL)isMe {
	return [[FTBUser currentUser] isEqual:self];
}

- (BOOL)canRecharge {
	return (self.totalWallet.integerValue < 100);
}

- (NSNumber *)localFunds {
	NSInteger funds = self.funds.integerValue;
	if (self.isMe) {
		for (FTBBet *bet in self.activeBets) {
			funds += bet.bid.integerValue;
			funds -= bet.match.myBetValue.floatValue;
		}
		NSMutableSet *rids = [NSMutableSet new];
		for (FTBMatch *match in self.pendingMatchesToSyncBet) {
			if (!match.myBet && ![rids containsObject:match.identifier]) {
				funds -= match.myBetValue.floatValue;
				[rids addObject:match.identifier];
			}
		}
	}
	
	if (FBTweakValue(@"Values", @"Profile", @"Wallet", 0, 0, HUGE_VAL)) {
		return @(FBTweakValue(@"Values", @"Profile", @"Wallet", 0, 0, HUGE_VAL));
	}
	
	return @(funds);
}

- (NSNumber *)localStake {
	NSInteger stake = 0;
	if (self.isMe) {
		for (FTBBet *bet in self.activeBets) {
			stake += bet.match.myBetValue.floatValue;
		}
		NSMutableSet *rids = [NSMutableSet new];
		for (FTBMatch *match in self.pendingMatchesToSyncBet) {
			if (!match.myBet && ![rids containsObject:match.identifier]) {
				stake += match.myBetValue.floatValue;
				[rids addObject:match.identifier];
			}
		}
	} else {
		stake = self.stake.integerValue;
	}
	
	if (FBTweakValue(@"Values", @"Profile", @"Stake", 0, 0, HUGE_VAL)) {
		return @(FBTweakValue(@"Values", @"Profile", @"Stake", 0, 0, HUGE_VAL));
	}
	
	return @(stake);
}

- (NSNumber *)toReturn {
	float toReturn = 0;
	if (self.isMe) {
		for (FTBBet *bet in self.activeBets) {
			toReturn += bet.match.myBetReturn.floatValue;
		}
		NSMutableSet *rids = [NSMutableSet new];
		for (FTBMatch *match in self.pendingMatchesToSyncBet) {
			if (!match.myBet && ![rids containsObject:match.identifier]) {
				toReturn += match.myBetReturn.floatValue;
				[rids addObject:match.identifier];
			}
		}
	} else {
		for (FTBBet *bet in self.activeBets) {
			toReturn += bet.toReturn.floatValue;
		}
	}
	
	if (FBTweakValue(@"Values", @"Profile", @"To Return", 0, 0, HUGE_VAL)) {
		return @(FBTweakValue(@"Values", @"Profile", @"To Return", 0, 0, HUGE_VAL));
	}
	
	return @(toReturn);
}

- (NSString *)toReturnString {
	return self.toReturn.integerValue > 0 ? @(nearbyint(self.toReturn.doubleValue)).limitedWalletStringValue : @"-";
}

- (NSNumber *)profit {
	float profit = 0;
	for (FTBBet *bet in self.activeBets) {
		profit += bet.reward.floatValue;
	}
	
	if (FBTweakValue(@"Values", @"Profile", @"Profit", 0, 0, HUGE_VAL)) {
		return @(FBTweakValue(@"Values", @"Profile", @"Profit", 0, 0, HUGE_VAL));
	}
	
	return @(profit);
}

- (NSString *)profitString {
	BOOL started = NO;
	for (FTBBet *bet in self.activeBets) {
		if (bet.match.status != FTBMatchStatusWaiting) {
			started = YES;
			break;
		}
	}
	
	if (FBTweakValue(@"Values", @"Profile", @"Profit", 0, 0, HUGE_VAL)) {
		started = YES;
	}
	
	return started ? @(nearbyint(self.profit.doubleValue)).limitedWalletStringValue : @"-";
}

- (NSNumber *)totalWallet {
	return @(self.localFunds.floatValue + self.localStake.floatValue);
}

- (NSNumber *)highestWallet {
	NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"funds" ascending:NO];
	NSDictionary *wallet = [self.history sortedArrayUsingDescriptors:@[descriptor]].firstObject;
	if (wallet) {
		return @(MAX(self.totalWallet.floatValue, [wallet[@"funds"] floatValue]));
	}
	
	return self.totalWallet;
}

- (NSDate *)highestWalletDate {
	NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"funds" ascending:NO];
	NSDictionary *wallet = [self.history sortedArrayUsingDescriptors:@[descriptor]].firstObject;
	if (wallet && [wallet[@"funds"] floatValue] > self.totalWallet.floatValue) {
		NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName];
		return [transformer reverseTransformedValue:wallet[@"date"]];
	}
	
	return [NSDate date];
}

- (NSMutableSet *)pendingMatchesToSyncBet {
	if (!_pendingMatchesToSyncBet) {
		_pendingMatchesToSyncBet = [NSMutableSet new];
	}
	return _pendingMatchesToSyncBet;
}

- (NSNumber *)numberOfFans {
	return @0;
}

- (BOOL)isFanOfUser:(FTBUser *)user {
	return NO;
}

- (NSNumber *)numberOfLeagues {
	return @(self.entries.count);
}

- (NSArray *)history {
	FTBUserSeason *history = self.seasons.firstObject;
	return history.rankings;
}

@end