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

@property (nonatomic, copy, readonly) NSNumber *funds;

@end

@interface FTBUserSeason : FTBModel

@property (nonatomic, strong, readonly) FTBSeason *season;
@property (nonatomic, copy, readonly) NSArray *rankings;
@property (nonatomic, copy, readonly) NSNumber *stake;
@property (nonatomic, copy, readonly) NSNumber *funds;
@property (nonatomic, copy, readonly) NSArray *evolution; // FTBUserSeasonEvolution

@end

@interface FTBUser : FTBModel

@property (nonatomic, copy, readonly) NSString *email;
@property (nonatomic, copy, readonly) NSString *username;
@property (nonatomic, copy, readonly) NSString *facebookId;
@property (nonatomic, copy, readonly) NSString *password;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *about;
@property (nonatomic, assign, readonly, getter=isVerified) BOOL verified;
@property (nonatomic, assign, readonly, getter=isFeatured) BOOL featured;
@property (nonatomic, copy, readonly) NSURL *pictureURL;
@property (nonatomic, copy, readonly) NSString *apnsToken;
@property (nonatomic, assign, readonly, getter=isActive) BOOL active;
@property (nonatomic, copy, readonly) NSString *country;
@property (nonatomic, copy, readonly) NSArray *entries; // FTBChampionship
@property (nonatomic, copy, readonly) NSArray *seasons; // FTBUserSeason

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

@end
