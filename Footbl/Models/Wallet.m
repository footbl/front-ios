//
//  Wallet.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/27/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "Championship.h"
#import "Wallet.h"

@interface Wallet ()

@end

#pragma mark Wallet

@implementation Wallet

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

#pragma mark - Instance Methods

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    self.championship = [Championship findByIdentifier:data[@"championship"] inManagedObjectContext:self.managedObjectContext];
    self.funds = data[@"funds"];
    self.stake = data[@"stake"];
    self.toReturn = data[@"toReturn"];
    self.profit = @(MAX(0, self.toReturn.integerValue - self.stake.integerValue));
}

@end