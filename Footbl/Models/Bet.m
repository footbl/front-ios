//
//  Bet.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/29/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SPHipster/SPHipster.h>
#import <TransformerKit/TransformerKit.h>
#import "Bet.h"
#import "Championship.h"
#import "NSNumber+Formatter.h"
#import "User.h"
#import "Wallet.h"

@interface Bet ()

@end

#pragma mark Bet

@implementation Bet

static CGFloat kBetSyncWaitTime = 3;

#pragma mark - Class Methods

+ (NSString *)resourcePath {
    SPLogError(@"Bet resource path should not be used.");
    return @"wallets/%@/bets";
}

+ (void)createWithMatch:(Match *)match bid:(NSNumber *)bid result:(MatchResult)result success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    FootblAPIFailureBlock customFailureBlock = ^(NSError *error) {
        [match.editableObject setBetTemporaryResult:0 value:nil];
        match.editableObject.betSyncing = NO;
        if (failure) failure(error);
    };
    
    [match.editableObject setBetTemporaryResult:result value:bid];
    
    if (match.betBlockKey) {
        cancel_block(match.betBlockKey);
    }
    
    NSUInteger key;
    perform_block_after_delay_k(kBetSyncWaitTime, &key, ^{
        match.editableObject.betSyncing = YES;
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
                    bet.wallet = match.championship.myWallet;
                    [bet updateWithData:responseObject];
                    requestSucceedWithBlock(operation, parameters, nil);
                    [match.championship.myWallet updateWithSuccess:^{
                        match.editableObject.betSyncing = NO;
                        [match setBetTemporaryResult:0 value:nil];
                        if (success) success();
                    } failure:failure];
                    [match updateWithSuccess:nil failure:nil];
                }];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (operation.response.statusCode == 500) {
                    error = [NSError errorWithDomain:FootblAPIErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"Error: insufient funds", @"")}];
                }
                requestFailedWithBlock(operation, parameters, error, customFailureBlock);
            }];
        } failure:customFailureBlock];
    });
    match.editableObject.betBlockKey = key;
}

+ (void)updateWithWallet:(Wallet *)wallet success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    NSString *key = [NSString stringWithFormat:@"%@%@", wallet.rid, API_DICTIONARY_KEY];
    [[self API] groupOperationsWithKey:key block:^{
        [[self API] ensureAuthenticationWithSuccess:^{
            NSMutableDictionary *parameters = [self generateParametersWithPage:API_CURRENT_PAGE(key)];
            [[self API] GET:[NSString stringWithFormat:@"users/%@/wallets/%@/bets", wallet.user.rid, wallet.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                API_APPEND_RESULT(responseObject, key);
                if ([[operation responseObject] count] == [self responseLimit]) {
                    API_APPEND_PAGE(key);
                    [FootblAPI performOperationWithoutGrouping:^{
                       [self updateWithWallet:wallet success:success failure:failure];
                    }];
                } else {
                    [self loadContent:API_RESULT(key) inManagedObjectContext:self.editableManagedObjectContext usingCache:wallet.bets enumeratingObjectsWithBlock:^(Bet *bet, NSDictionary *contentEntry) {
                        bet.wallet = wallet;
                    } deletingUntouchedObjectsWithBlock:^(NSSet *untouchedObjects) {
                        [self.editableManagedObjectContext deleteObjects:untouchedObjects];
                    }];
                    requestSucceedWithBlock(operation, parameters, nil);
                    [[self API] finishGroupedOperationsWithKey:key error:nil];
                    API_RESET_KEY(key);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                requestFailedWithBlock(operation, parameters, error, nil);
                [[self API] finishGroupedOperationsWithKey:key error:error];
                API_RESET_KEY(key);
            }];
        } failure:^(NSError *error) {
            [[self API] finishGroupedOperationsWithKey:key error:error];
        }];
    } success:success failure:failure];
}

#pragma mark - Instance Methods

- (NSString *)resourcePath {
    return [NSString stringWithFormat:@"championships/%@/matches/%@/bets", self.wallet.championship.rid, self.match.rid];
}

- (void)updateWithBid:(NSNumber *)bid result:(MatchResult)result success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    FootblAPIFailureBlock customFailureBlock = ^(NSError *error) {
        [self.match.editableObject setBetTemporaryResult:0 value:nil];
        self.match.editableObject.betSyncing = NO;
        if (failure) failure(error);
    };
    
    [self.match.editableObject setBetTemporaryResult:result value:bid];
    
    if (self.match.betBlockKey) {
        cancel_block(self.match.betBlockKey);
    }
    
    NSUInteger key;
    perform_block_after_delay_k(kBetSyncWaitTime, &key, ^{
        self.match.editableObject.betSyncing = YES;
        [[self API] ensureAuthenticationWithSuccess:^{
            NSMutableDictionary *parameters = [self generateDefaultParameters];
            NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName];
            parameters[@"date"] = [transformer transformedValue:[NSDate date]];
            parameters[@"result"] = MatchResultToString(result);
            parameters[@"bid"] = bid;
            [[self API] PUT:[self.resourcePath stringByAppendingPathComponent:self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self.editableManagedObjectContext performBlock:^{
                    [self updateWithData:responseObject];
                    self.match.editableObject.localUpdatedAt = [NSDate date];
                    requestSucceedWithBlock(operation, parameters, nil);
                    [self.match.championship.myWallet updateWithSuccess:^{
                        self.match.editableObject.betSyncing = NO;
                        [self.match.editableObject setBetTemporaryResult:0 value:nil];
                        if (success) success();
                    } failure:failure];
                    [self.match updateWithSuccess:nil failure:nil];
                }];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (operation.response.statusCode == 500) {
                    error = [NSError errorWithDomain:FootblAPIErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"Error: insufient funds", @"")}];
                }
                requestFailedWithBlock(operation, parameters, error, customFailureBlock);
            }];
        } failure:customFailureBlock];
    });
    self.match.editableObject.betBlockKey = key;
}

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName];
    self.date = [transformer reverseTransformedValue:data[@"date"]];
    if ([data[@"match"] isKindOfClass:[NSDictionary class]]) {
        self.match = [Match findByIdentifier:data[@"match"][kAPIIdentifierKey] inManagedObjectContext:self.managedObjectContext];
        [self.match updateWithData:data[@"match"]];
    } else {
        self.match = [Match findByIdentifier:data[@"match"] inManagedObjectContext:self.managedObjectContext];
    }
    self.value = data[@"bid"];
    self.result = @(MatchResultFromString(data[@"result"]));
}

- (void)deleteWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    FootblAPIFailureBlock customFailureBlock = ^(NSError *error) {
        [self.match.editableObject setBetTemporaryResult:0 value:nil];
        self.match.editableObject.betSyncing = NO;
        if (failure) failure(error);
    };
    
    Match *match = self.match.editableObject;
    [self.match.editableObject setBetTemporaryResult:0 value:@0];
    
    if (self.match.betBlockKey) {
        cancel_block(self.match.betBlockKey);
    }
    
    NSUInteger key;
    perform_block_after_delay_k(kBetSyncWaitTime, &key, ^{
        self.match.editableObject.betSyncing = YES;
        [[self API] ensureAuthenticationWithSuccess:^{
            NSMutableDictionary *parameters = [self generateDefaultParameters];
            [[self API] DELETE:[self.resourcePath stringByAppendingPathComponent:self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self.editableManagedObjectContext performBlock:^{
                    [self.editableManagedObjectContext deleteObject:self];
                    requestSucceedWithBlock(operation, parameters, nil);
                    [match.championship.myWallet updateWithSuccess:^{
                        [match setBetTemporaryResult:0 value:nil];
                        match.betSyncing = NO;
                        if (success) success();
                    } failure:failure];
                    [match updateWithSuccess:nil failure:nil];
                }];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                requestFailedWithBlock(operation, parameters, error, customFailureBlock);
            }];
        } failure:customFailureBlock];
    });
    self.match.editableObject.betBlockKey = key;
}

- (User *)user {
    return self.wallet.user;
}

- (BOOL)isMine {
    return self.user.isMeValue;
}

- (NSString *)valueString {
    return self.valueValue == 0 ? @"-" : @(self.value.integerValue).walletStringValue;
}

- (NSNumber *)toReturn {
    switch (self.resultValue) {
        case MatchResultHost:
            return @(self.valueValue * self.match.earningsPerBetForHost.floatValue);
        case MatchResultDraw:
            return @(self.valueValue * self.match.earningsPerBetForDraw.floatValue);
        case MatchResultGuest:
            return @(self.valueValue * self.match.earningsPerBetForGuest.floatValue);
        default:
            return @0;
    }
}

- (NSString *)toReturnString {
    return self.valueValue == 0 ? @"-" : @(nearbyintf(self.toReturn.floatValue)).walletStringValue;
}

- (NSNumber *)reward {
    if (self.valueValue == 0 || self.match.status == MatchStatusWaiting) {
        return @0;
    }
    
    if (self.resultValue == self.match.result) {
        return @(self.toReturn.floatValue - self.valueValue);
    } else {
        return @(-self.valueValue);
    }
}

- (NSString *)rewardString {
    if (self.valueValue == 0 || self.match.status == MatchStatusWaiting) {
        return @"-";
    }
    
    return @(nearbyintf(self.reward.floatValue)).walletStringValue;
}

@end
