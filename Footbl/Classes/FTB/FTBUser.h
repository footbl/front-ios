//
//  FTBUser.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBModel.h"

@class FTBUser;
@class FTBSeason;
@class FTBChampionship;

@interface FTBUserSeasonEvolution : FTBModel

@property (nonatomic, copy) NSNumber *funds;

@end

@interface FTBUserSeason : FTBModel

@property (nonatomic, strong) FTBSeason *season;
@property (nonatomic, copy) NSArray<NSNumber *> *rankings;
@property (nonatomic, copy) NSNumber *stake;
@property (nonatomic, copy) NSNumber *funds;
@property (nonatomic, copy) NSArray<FTBUserSeasonEvolution *> *evolution;

@end

@interface FTBBaseUser : FTBModel

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *facebookId;
//@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *about;
@property (nonatomic, assign, getter=isVerified) BOOL verified;
@property (nonatomic, assign, getter=isFeatured) BOOL featured;
@property (nonatomic, copy) NSURL *pictureURL;
@property (nonatomic, copy) NSString *apnsToken;
@property (nonatomic, assign, getter=isActive) BOOL active;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSArray<FTBChampionship *> *entries;
@property (nonatomic, copy) NSArray<FTBUserSeason *> *seasons;
@property (nonatomic, copy) NSNumber *funds;
@property (nonatomic, copy) NSNumber *stake;
@property (nonatomic, copy) NSNumber *ranking;
@property (nonatomic, copy) NSNumber *previousRanking;

@property (nonatomic, assign, getter=isNotificationsEnabled) BOOL notificationsEnabled;
@property (nonatomic, copy) NSMutableSet *pendingMatchesToSyncBet;

+ (instancetype)currentUser;

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
- (NSNumber *)numberOfFans;
- (BOOL)isFanOfUser:(FTBUser *)user;
- (NSNumber *)numberOfLeagues;
- (NSArray *)history;

@end

@interface FTBUser : FTBBaseUser

@property (nonatomic, copy) NSArray<FTBUser *> *starred;

@end
