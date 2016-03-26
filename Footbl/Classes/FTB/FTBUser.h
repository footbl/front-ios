//
//  FTBUser.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBModel.h"

@class FTBBet;
@class FTBMatch;

@interface FTBHistory : FTBModel

@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSNumber *stake;
@property (nonatomic, copy) NSNumber *funds;

@end

@interface FTBUser : FTBModel

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *facebookId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *about;
@property (nonatomic, assign, getter=isVerified) BOOL verified;
@property (nonatomic, assign, getter=isFeatured) BOOL featured;
@property (nonatomic, copy) NSURL *pictureURL;
@property (nonatomic, copy) NSString *apnsToken;
@property (nonatomic, assign, getter=isActive) BOOL active;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSNumber *funds;
@property (nonatomic, copy) NSNumber *stake;
@property (nonatomic, copy) NSNumber *wallet;
@property (nonatomic, copy) NSNumber *ranking;
@property (nonatomic, copy) NSNumber *previousRanking;
@property (nonatomic, copy) NSArray<FTBHistory *> *history;

@property (nonatomic, assign, getter=isNotificationsEnabled) BOOL notificationsEnabled;

- (void)addBet:(FTBBet *)bet;
- (void)addBets:(NSArray<FTBBet *> *)bets;
- (FTBBet *)betWithIdentifier:(NSString *)identifier;
- (FTBBet *)betForMatch:(FTBMatch *)match;
- (void)removeBet:(FTBBet *)bet;

+ (instancetype)currentUser;

- (BOOL)isMe;
- (BOOL)canRecharge;
- (NSNumber *)toReturn;
- (NSString *)toReturnString;
- (NSNumber *)profit;
- (NSString *)profitString;
- (NSNumber *)totalWallet;
- (NSNumber *)highestWallet;
- (NSDate *)highestWalletDate;
- (NSNumber *)numberOfFans;
- (BOOL)isFanOfUser:(FTBUser *)user;

@end
