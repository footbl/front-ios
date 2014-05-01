//
//  Wallet.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/27/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "Bet.h"
#import "Championship.h"
#import "Match.h"
#import "Wallet.h"

@interface Wallet ()

@end

#pragma mark Wallet

@implementation Wallet

@synthesize pendingMatchesToSyncBet = _pendingMatchesToSyncBet;

#pragma mark - Class Methods

+ (NSString *)resourcePath {
    return @"wallets";
}

+ (void)ensureWalletWithChampionship:(Championship *)championship success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    if (championship.wallet) {
        if (success) success();
        return;
    }
    
    [self updateWithSuccess:^{
        if (championship.wallet) {
            if (success) success();
        } else {
            [self createWithChampionship:championship success:success failure:failure];
        }
    } failure:failure];
}

+ (void)createWithChampionship:(Championship *)championship success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [self createWithParameters:@{@"championship": championship.rid} success:success failure:failure];    
}

#pragma mark - Getters/Setters

- (NSMutableArray *)pendingMatchesToSyncBet {
    if (!_pendingMatchesToSyncBet) {
        _pendingMatchesToSyncBet = [NSMutableArray new];
    }
    return _pendingMatchesToSyncBet;
}

#pragma mark - Instance Methods

- (NSNumber *)localFunds {
    NSInteger funds = self.funds.integerValue;
    for (Match *match in self.pendingMatchesToSyncBet) {
        funds += match.bet.valueValue;
        funds -= match.tempBetValue.integerValue;
    }
    
    return @(funds);
}

- (NSNumber *)localStake {
    NSInteger stake = self.stake.integerValue;
    for (Match *match in self.pendingMatchesToSyncBet) {
        stake -= match.bet.valueValue;
        stake += match.tempBetValue.integerValue;
    }
    
    return @(stake);
}

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    self.championship = [Championship findOrCreateByIdentifier:data[@"championship"][kAPIIdentifierKey] inManagedObjectContext:self.managedObjectContext];
    [self.championship updateWithData:data[@"championship"]];
    
    self.active = data[@"active"];
    self.funds = data[@"funds"];
    self.stake = data[@"stake"];
    self.toReturn = data[@"toReturn"];
    self.profit = @(MAX(0, self.toReturn.integerValue - self.stake.integerValue));
}

@end
