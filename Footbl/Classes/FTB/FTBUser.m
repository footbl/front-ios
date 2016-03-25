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

#pragma mark - FTBHistory

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

#pragma mark - FTBUser

@interface FTBUser ()

@property (nonatomic, strong) NSMutableSet<FTBBet *> *bets;

@end

@implementation FTBUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	NSDictionary *keyPaths = @{@"email": @"email",
							   @"username": @"username",
							   @"facebookId": @"facebookId",
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

- (NSNumber *)stake {
    NSInteger stake = 0;
    for (FTBBet *bet in self.bets) {
        stake += bet.bid.integerValue;
    }
    return @(stake);
}

- (NSMutableSet<FTBBet *> *)bets {
    if (!_bets) {
        _bets = [[NSMutableSet alloc] init];
    }
    return _bets;
}

- (void)addBet:(FTBBet *)bet {
    NSInteger stake = self.stake.integerValue;
    NSInteger funds = self.funds.integerValue;
    
    FTBBet *oldBet = [self.bets member:bet];
    if (oldBet) {
        stake -= oldBet.bid.integerValue;
        funds += oldBet.bid.integerValue;
        
        [self.bets removeObject:oldBet];
    }
    
    self.stake = @(stake + bet.bid.integerValue);
    self.funds = @(funds - bet.bid.integerValue);
    
    [self.bets addObject:bet];
}

- (void)addBets:(NSArray<FTBBet *> *)bets {
    for (FTBBet *bet in bets) {
        [self addBet:bet];
    }
}

- (FTBBet *)betForMatch:(FTBMatch *)match {
    for (FTBBet *bet in self.bets) {
        if ([bet.match isEqual:match]) {
            return bet;
        }
    }
    
    return nil;
}

- (void)removeBet:(FTBBet *)bet {
    FTBBet *oldBet = [self.bets member:bet];
    if (oldBet) {
        self.stake = @(self.stake.integerValue - oldBet.bid.integerValue);
        self.funds = @(self.funds.integerValue + oldBet.bid.integerValue);
        [self.bets removeObject:oldBet];
    }
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

- (NSNumber *)toReturn {
	float toReturn = 0;
    for (FTBBet *bet in self.activeBets) {
        toReturn += bet.toReturn.floatValue;
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
	
	return started ? @(nearbyint(self.profit.doubleValue)).limitedWalletStringValue : @"-";
}

- (NSNumber *)totalWallet {
	return @(self.funds.floatValue + self.stake.floatValue);
}

- (NSNumber *)highestWallet {
	NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"funds" ascending:NO];
	FTBHistory *history = [self.history sortedArrayUsingDescriptors:@[descriptor]].firstObject;
	if (history) {
		return @(MAX(self.totalWallet.floatValue, history.funds.floatValue));
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

- (NSNumber *)numberOfFans {
	return @0;
}

- (BOOL)isFanOfUser:(FTBUser *)user {
	return NO;
}

@end
