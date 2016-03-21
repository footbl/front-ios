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
#import "FTBClient.h"
#import "NSNumber+Formatter.h"

#import <TransformerKit/TTTDateTransformers.h>

@implementation FTBHistory

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	NSDictionary *keyPaths = @{@"date": @"date",
                               @"stake": @"stake",
                               @"funds": @"funds"};
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}

+ (NSValueTransformer *)dateJSONTransformer {
    return [super dateJSONTransformer];
}

@end

@implementation FTBUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	NSDictionary *keyPaths = @{@"email": @"email",
							   @"username": @"username",
							   @"facebookId": @"facebookId",
//							   @"password": @"password",
							   @"name": @"name",
							   @"about": @"about",
							   @"verified": @"verified",
							   @"featured": @"featured",
							   @"pictureURL": @"picture",
							   @"apnsToken": @"apnsToken",
							   @"active": @"active",
							   @"country": @"country",
							   @"funds": @"funds",
							   @"stake": @"stake",
                               @"history": @"history"};
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}

+ (NSValueTransformer *)historyJSONTransformer {
	return [MTLJSONAdapter arrayTransformerWithModelClass:[FTBHistory class]];
}

#pragma mark - Helpers

+ (instancetype)currentUser {
	return [[FTBClient client] user];
}

- (NSSet *)bets {
	return nil;
}

- (NSSet *)activeBets {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bid > 0 AND match.finished = NO AND match != nil"];
	return [self.bets filteredSetUsingPredicate:predicate];
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
	FTBHistory *wallet = [self.history sortedArrayUsingDescriptors:@[descriptor]].firstObject;
	if (wallet) {
		return @(MAX(self.totalWallet.floatValue, wallet.funds.floatValue));
	}
	
	return self.totalWallet;
}

- (NSDate *)highestWalletDate {
	NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"funds" ascending:NO];
	FTBHistory *wallet = [self.history sortedArrayUsingDescriptors:@[descriptor]].firstObject;
	if (wallet && wallet.funds.floatValue > self.totalWallet.floatValue) {
        return wallet.date;
	}
	
	return [NSDate date];
}

- (NSMutableSet *)pendingMatchesToSyncBet {
	if (!_pendingMatchesToSyncBet) {
		_pendingMatchesToSyncBet = [[NSMutableSet alloc] init];
	}
	return _pendingMatchesToSyncBet;
}

- (NSNumber *)numberOfFans {
	return @0;
}

- (BOOL)isFanOfUser:(FTBUser *)user {
	return NO;
}

@end
