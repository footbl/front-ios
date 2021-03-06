//
//  FTBUser.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBUser.h"
#import "FTBBet.h"
#import "FTBChallenge.h"
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

#pragma mark - Bets

- (NSMutableSet<FTBBet *> *)bets {
    if (!_bets) {
        _bets = [[NSMutableSet alloc] init];
    }
    return _bets;
}

- (NSSet *)activeBets {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"match != nil && match.finished == NO && bid > 0"];
    return [self.bets filteredSetUsingPredicate:predicate];
}

- (void)addBet:(FTBBet *)bet {
    [self removeBet:bet];
    
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
    return [self.bets filteredSetUsingPredicate:predicate].anyObject;
}

- (FTBBet *)betForMatch:(FTBMatch *)match {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"match == %@", match];
    return [self.bets filteredSetUsingPredicate:predicate].anyObject;
}

- (void)removeBet:(FTBBet *)bet {
    FTBBet *oldBet = [self.bets member:bet];
    if (oldBet) {
        [self.bets removeObject:oldBet];
        [bet.match updatePotByRemovingBet:oldBet];
    }
}

#pragma mark - Helpers

+ (instancetype)currentUser {
    return [[FTBClient client] user];
}

- (BOOL)isMe {
	return [[[self class] currentUser] isEqual:self];
}

- (NSNumber *)funds {
    return @(self.wallet.integerValue - self.stake.integerValue);
}

- (NSNumber *)stake {
    return [self.activeBets valueForKeyPath:@"@sum.bid"];
}

- (NSString *)stakeString {
    return self.stake.integerValue > 0 ? @(nearbyint(self.stake.doubleValue)).limitedWalletStringValue : @"-";
}

- (BOOL)canRecharge {
	return (self.wallet.integerValue < 100);
}

- (NSNumber *)toReturn {
	return [self.activeBets valueForKeyPath:@"@sum.toReturn"];
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

- (NSNumber *)highestWallet {
	NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"funds" ascending:NO];
	FTBHistory *history = [self.history sortedArrayUsingDescriptors:@[descriptor]].firstObject;
	if (history) {
		return @(MAX(self.wallet.floatValue, history.funds.floatValue));
	}
	
	return self.wallet;
}

- (NSDate *)highestWalletDate {
	NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"funds" ascending:NO];
	FTBHistory *wallet = [self.history sortedArrayUsingDescriptors:@[descriptor]].firstObject;
	if (wallet && wallet.funds.floatValue > self.wallet.floatValue) {
        return wallet.date;
	}
	
	return [NSDate date];
}

//- (NSURL *)pictureURL {
//    return [NSURL URLWithString:@"https://pbs.twimg.com/profile_images/1688231443/image.jpg"];
//}

@end
