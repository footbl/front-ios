//
//  FTBUser.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBUser.h"
#import "FTBBet.h"
#import "FTBChampionship.h"
#import "FTBClient.h"
#import "FTBMatch.h"
#import "FTBSeason.h"
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
							   @"ISOCountryCode": @"country",
							   @"funds": @"funds",
							   @"stake": @"stake",
                               @"history": @"history"};
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}

+ (NSValueTransformer *)historyJSONTransformer {
	return [MTLJSONAdapter arrayTransformerWithModelClass:[FTBHistory class]];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self) {
        self.wallet = @(_funds.integerValue + _stake.integerValue);
        self.country = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:self.ISOCountryCode];
    }
    return self;
}

#pragma mark - Helpers

+ (instancetype)currentUser {
	return [[FTBClient client] user];
}

- (NSNumber *)stake {
    NSInteger stake = 0;
    for (FTBBet *bet in self.activeBets) {
        stake += bet.bid.integerValue;
    }
    return @(stake);
}

- (NSNumber *)funds {
    return @(self.wallet.integerValue - self.stake.integerValue);
}

- (NSMutableSet<FTBBet *> *)bets {
    if (!_bets) {
        _bets = [[NSMutableSet alloc] init];
    }
    return _bets;
}

- (NSSet *)activeBets {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"match != nil && match.finished == NO && match.elapsed == 0 && bid > 0"];
    return [self.bets filteredSetUsingPredicate:predicate];
}

- (void)addBet:(FTBBet *)bet {
    FTBBet *oldBet = [self.bets member:bet];
    
    if (oldBet) {
        [self.bets removeObject:oldBet];
        [bet.match updatePotByRemovingBet:oldBet];
    }
    
    [self.bets addObject:bet];
    [bet.match updatePotByAddingBet:bet];
}

- (void)addBets:(NSArray<FTBBet *> *)bets {
    for (FTBBet *bet in bets) {
        [self addBet:bet];
    }
}

- (FTBBet *)betWithIdentifier:(NSString *)identifier {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
    NSSet *results = [self.bets filteredSetUsingPredicate:predicate];
    return results.anyObject;
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
        [self.bets removeObject:oldBet];
        [bet.match updatePotByRemovingBet:oldBet];
    }
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
    return self.wallet;
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

@end
