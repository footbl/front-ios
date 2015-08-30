//
//  FTBUser.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBModel.h"

@class FTBSeason;

@interface FTBUserSeasonEvolution : FTBModel

@property (nonatomic, copy) NSNumber *funds;

@end

@interface FTBUserSeason : FTBModel

@property (nonatomic, strong) FTBSeason *season;
@property (nonatomic, copy) NSArray *rankings;
@property (nonatomic, copy) NSNumber *stake;
@property (nonatomic, copy) NSNumber *funds;
@property (nonatomic, copy) NSArray *evolution; // FTBUserSeasonEvolution

@end

@interface FTBUser : FTBModel

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *facebookId;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *about;
@property (nonatomic, assign, getter=isVerified) BOOL verified;
@property (nonatomic, assign, getter=isFeatured) BOOL featured;
@property (nonatomic, copy) NSURL *pictureURL;
@property (nonatomic, copy) NSString *apnsToken;
@property (nonatomic, assign, getter=isActive) BOOL active;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSArray *entries; // FTBChampionship
@property (nonatomic, copy) NSArray *seasons; // FTBUserSeason

@property (nonatomic, assign, getter=isNotificationsEnabled) BOOL notificationsEnabled;

- (BOOL)isMe;
- (BOOL)canRecharge;
- (NSNumber *)localFunds;
- (NSNumber *)localStake;
- (NSNumber *)toReturn;
- (NSString *)toReturnString;
- (NSNumber *)profit;
- (NSString *)profitString;
- (NSNumber *)totalWallet;
- (NSNumber *)highestWallet;
- (NSDate *)highestWalletDate;
- (float)fundsValue;
- (float)stakeValue;
- (NSMutableSet *)pendingMatchesToSyncBet;
- (NSNumber *)numberOfFans;
- (BOOL)isFanOfUser:(FTBUser *)user;
- (NSNumber *)numberOfLeagues;
- (NSNumber *)ranking;
- (NSNumber *)previousRanking;
- (NSArray *)history;

@end
