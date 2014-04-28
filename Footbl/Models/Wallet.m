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

+ (void)updateWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [[self API] GET:@"wallets" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self loadContent:responseObject inManagedObjectContext:self.editableManagedObjectContext usingCache:nil enumeratingObjectsWithBlock:nil deletingUntouchedObjectsWithBlock:^(NSSet *untouchedObjects) {
                [[self editableManagedObjectContext] deleteObjects:untouchedObjects];
                requestSucceedWithBlock(operation, parameters, success);
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

+ (void)createWithChampionship:(Championship *)championship success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        parameters[@"championship"] = championship.rid;
        [[self API] POST:@"wallets" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.editableManagedObjectContext performBlock:^{
                Wallet *wallet = [NSEntityDescription insertNewObjectForEntityForName:@"Wallet" inManagedObjectContext:self.editableManagedObjectContext];
                wallet.rid = responseObject[kAPIIdentifierKey];
                wallet.championship = championship;
                [wallet updateWithData:responseObject];
                SaveManagedObjectContext(self.editableManagedObjectContext);
                requestSucceedWithBlock(operation, parameters, success);
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

#pragma mark - Instance Methods

- (void)updateWithData:(NSDictionary *)data {
    self.championship = [Championship findByIdentifier:data[@"championship"] inManagedObjectContext:self.managedObjectContext];
    self.funds = data[@"funds"];
    self.stake = data[@"stake"];
    self.toReturn = data[@"toReturn"];
    self.profit = @(MAX(0, self.toReturn.integerValue - self.stake.integerValue));
}

- (void)updateWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [[self API] GET:[@"wallets/" stringByAppendingString:self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.editableManagedObjectContext performBlock:^{
                [self.editableObject updateWithData:responseObject];
                SaveManagedObjectContext(self.editableManagedObjectContext);
                requestSucceedWithBlock(operation, parameters, success);
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

@end
