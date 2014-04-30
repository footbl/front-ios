//
//  Bet.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/29/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <TransformerKit/TransformerKit.h>
#import "Bet.h"
#import "Championship.h"
#import "Wallet.h"

@interface Bet ()

@end

#pragma mark Bet

@implementation Bet

#pragma mark - Class Methods

+ (NSString *)resourcePath {
    SPLogError(@"Bet resource path should not be used.");
    return @"wallets/%@/bets";
}

+ (void)createWithMatch:(Match *)match bid:(NSNumber *)bid result:(MatchResult)result success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName];
        parameters[@"date"] = [transformer transformedValue:[NSDate date]];
        parameters[@"bid"] = bid;
        parameters[@"result"] = MatchResultToString(result);
        [[self API] POST:[NSString stringWithFormat:@"championships/%@/matches/%@/bets", match.championship.rid, match.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.editableManagedObjectContext performBlock:^{
                Bet *bet = [NSEntityDescription insertNewObjectForEntityForName:@"Bet" inManagedObjectContext:self.editableManagedObjectContext];
                bet.match = match;
                bet.wallet = match.championship.wallet;
                [bet updateWithData:responseObject];
                SaveManagedObjectContext(self.editableManagedObjectContext);
                requestSucceedWithBlock(operation, parameters, success);
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

+ (void)updateWithWallet:(Wallet *)wallet success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [[self API] GET:[NSString stringWithFormat:@"wallets/%@/bets", wallet.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self loadContent:responseObject inManagedObjectContext:self.editableManagedObjectContext usingCache:wallet.bets enumeratingObjectsWithBlock:^(Bet *bet, NSDictionary *contentEntry) {
                bet.wallet = wallet;
            } deletingUntouchedObjectsWithBlock:^(NSSet *untouchedObjects) {
                [self.editableManagedObjectContext deleteObjects:untouchedObjects];
            }];
            requestSucceedWithBlock(operation, parameters, success);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

#pragma mark - Instance Methods

- (NSString *)resourcePath {
    return [NSString stringWithFormat:@"championships/%@/matches/%@/bets", self.wallet.championship.rid, self.match.rid];
}

- (void)updateWithBid:(NSNumber *)bid result:(MatchResult)result success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName];
        parameters[@"date"] = [transformer transformedValue:[NSDate date]];
        parameters[@"result"] = MatchResultToString(result);
        parameters[@"bid"] = bid;
        [[self API] PUT:[self.resourcePath stringByAppendingPathComponent:self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.editableManagedObjectContext performBlock:^{
                [self updateWithData:responseObject];
                SaveManagedObjectContext(self.editableManagedObjectContext);
                requestSucceedWithBlock(operation, parameters, success);
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName];
    self.date = [transformer reverseTransformedValue:data[@"date"]];
    self.match = [Match findByIdentifier:data[@"match"] inManagedObjectContext:self.managedObjectContext];
    self.value = data[@"bid"];
    self.result = @(MatchResultFromString(data[@"result"]));
    self.reward = data[@"reward"];
}

- (void)deleteWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [[self API] DELETE:[self.resourcePath stringByAppendingPathComponent:self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.editableManagedObjectContext performBlock:^{
                [self.editableManagedObjectContext deleteObject:self];
                SaveManagedObjectContext(self.editableManagedObjectContext);
                requestSucceedWithBlock(operation, parameters, success);
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

@end
