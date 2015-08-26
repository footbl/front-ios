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
#import "FTAuthenticationManager.h"

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
							   @"seasons": @"seasons"};
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}

+ (NSValueTransformer *)entriesJSONTransformer {
	return [MTLJSONAdapter arrayTransformerWithModelClass:[FTBChampionship class]];
}

+ (NSValueTransformer *)seasonsJSONTransformer {
	return [MTLJSONAdapter arrayTransformerWithModelClass:[FTBUserSeason class]];
}

#pragma mark - Helpers

- (BOOL)isMe {
	return [[[FTAuthenticationManager sharedManager] user] isEqual:self];
}

- (BOOL)canRecharge {
	return YES;
}

- (NSNumber *)localFunds {
	return @0;
}

- (NSNumber *)localStake {
	return @0;
}

- (NSNumber *)toReturn {
	return @0;
}

- (NSString *)toReturnString {
	return @"0";
}

- (NSNumber *)profit {
	return @0;
}

- (NSString *)profitString {
	return @"0";
}

- (NSNumber *)totalWallet {
	return @0;
}

- (NSNumber *)highestWallet {
	return @0;
}

- (NSDate *)highestWalletDate {
	return nil;
}

- (float)fundsValue {
	return 0;
}

- (float)stakeValue {
	return 0;
}

- (NSMutableSet *)pendingMatchesToSyncBet {
	return nil;
}

@end
