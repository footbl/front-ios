//
//  Wallet.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/27/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "_Wallet.h"

@interface Wallet : _Wallet

@property (strong, nonatomic) NSMutableArray *pendingMatchesToSyncBet;

+ (void)ensureWalletWithChampionship:(Championship *)championship success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
+ (void)updateWithUser:(User *)user success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)rechargeWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (NSSet *)activeBets;
- (NSNumber *)localFunds;
- (NSNumber *)localStake;
- (NSNumber *)toReturn;
- (NSString *)toReturnString;
- (NSNumber *)profit;
- (NSString *)profitString;
- (NSArray *)lastActiveRounds;
- (BOOL)canRecharge;

@end
