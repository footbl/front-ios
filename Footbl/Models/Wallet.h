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
- (NSNumber *)localFunds;
- (NSNumber *)localStake;

@end
