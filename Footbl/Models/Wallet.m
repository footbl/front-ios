//
//  Wallet.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/27/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <CargoBay/CargoBay.h>
#import <RMStore/RMStore.h>
#import "Bet.h"
#import "Championship.h"
#import "Match.h"
#import "User.h"
#import "Wallet.h"

@interface Wallet ()

@end

#pragma mark Wallet

@implementation Wallet

@synthesize pendingMatchesToSyncBet = _pendingMatchesToSyncBet;

#pragma mark - Class Methods

+ (NSString *)resourcePath {
    SPLogError(@"Wallet resource path should not be used.");
    return @"users/%@/wallets";
}

+ (void)ensureWalletWithChampionship:(Championship *)championship success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    if (championship.myWallet) {
        if (success) success();
        return;
    }
    
    [self updateWithSuccess:^{
        if (championship.myWallet) {
            if (success) success();
        } else {
            [self createWithChampionship:championship success:success failure:failure];
        }
    } failure:failure];
}

+ (void)createWithChampionship:(Championship *)championship success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [self createWithParameters:@{@"championship": championship.rid} success:success failure:failure];    
}

+ (void)updateWithUser:(User *)user success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    NSString *key = [NSString stringWithFormat:@"%@%@", user.rid, API_DICTIONARY_KEY];
    [[self API] groupOperationsWithKey:key block:^{
        [[self API] ensureAuthenticationWithSuccess:^{
            NSMutableDictionary *parameters = [self generateParametersWithPage:API_CURRENT_PAGE(key)];
            [[self API] GET:[NSString stringWithFormat:@"users/%@/wallets", user.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                API_APPEND_RESULT(responseObject, key);
                if ([[operation responseObject] count] == [self responseLimit]) {
                    API_APPEND_PAGE(key);
                    [FootblAPI performOperationWithoutGrouping:^{
                        [self updateWithUser:user success:success failure:failure];
                    }];
                } else {
                    [self loadContent:API_RESULT(key) inManagedObjectContext:self.editableManagedObjectContext usingCache:user.wallets enumeratingObjectsWithBlock:^(Wallet *object, NSDictionary *contentEntry) {
                        object.user = user;
                    } deletingUntouchedObjectsWithBlock:^(NSSet *untouchedObjects) {
                        [self.editableManagedObjectContext deleteObjects:untouchedObjects];
                    }];
                    [[self API] finishGroupedOperationsWithKey:key error:nil];
                    requestSucceedWithBlock(operation, parameters, success);
                    API_RESET_KEY(key);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [[self API] finishGroupedOperationsWithKey:key error:error];
                requestFailedWithBlock(operation, parameters, error, failure);
                API_RESET_KEY(key);
            }];
        } failure:^(NSError *error) {
            [[self API] finishGroupedOperationsWithKey:key error:error];
            if (failure) failure(error);
        }];
    } success:success failure:failure];
}

#pragma mark - Getters/Setters

- (NSMutableArray *)pendingMatchesToSyncBet {
    if (!_pendingMatchesToSyncBet) {
        _pendingMatchesToSyncBet = [NSMutableArray new];
    }
    return _pendingMatchesToSyncBet;
}

#pragma mark - Instance Methods

- (NSString *)resourcePath {
    return [NSString stringWithFormat:@"users/%@/wallets", self.user.rid];
}

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
    self.user = [User findOrCreateByIdentifier:data[@"user"][kAPIIdentifierKey] inManagedObjectContext:self.managedObjectContext];
    [self.user updateWithData:data[@"user"]];
    
    self.active = data[@"active"];
    self.funds = data[@"funds"];
    self.stake = data[@"stake"];
    self.toReturn = data[@"toReturn"];
    self.profit = @(MAX(0, self.toReturn.integerValue - self.stake.integerValue));
    self.ranking = nil;
}

- (void)rechargeWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[RMStore defaultStore] requestProducts:[NSSet setWithArray:@[@"com.madeatsampa.Footbl.recharge"]] success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        SKProduct *product = products.firstObject;
        if (product) {
            [[RMStore defaultStore] addPayment:product.productIdentifier success:^(SKPaymentTransaction *transaction) {
                [[CargoBay sharedManager] verifyTransaction:transaction password:nil success:^(NSDictionary *receipt) {
                    [[self API] ensureAuthenticationWithSuccess:^{
                        NSMutableDictionary *parameters = [self generateDefaultParameters];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                        parameters[@"receipt"] = CBBase64EncodedStringFromData(transaction.transactionReceipt);
#pragma clang diagnostic pop
                        [[self API] POST:[NSString stringWithFormat:@"users/%@/wallets/%@/recharge", self.user.rid, self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            [self updateWithData:responseObject];
                            requestSucceedWithBlock(operation, parameters, success);
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            requestFailedWithBlock(operation, parameters, error, failure);
                        }];
                    } failure:failure];
                } failure:^(NSError *error) {
                    if (failure) failure(error);
                }];
            } failure:^(SKPaymentTransaction *transaction, NSError *error) {
                if (failure) failure(error);
            }];
        } else {
            if (failure) failure(nil);
        }
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

@end
