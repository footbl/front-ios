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
    return @"bets";
}

+ (NSDictionary *)relationshipProperties {
    return @{@"match": [Match class], @"user": [User class]};
}

+ (NSArray *)ignoredProperties {
    return [[super ignoredProperties] arrayByAddingObjectsFromArray:@[@"result", @"reward"]];
}

+ (void)createWithMatch:(Match *)match bid:(NSNumber *)bid result:(MatchResult)result success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    FTOperationErrorBlock customFailureBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [match.editableObject setBetTemporaryResult:0 value:nil];
        match.editableObject.betSyncing = NO;
        if (failure) failure(operation, error);
    };
    
    [match.editableObject setBetTemporaryResult:result value:bid];
    
    if (match.betBlockKey) {
        cancel_block(match.betBlockKey);
    }
    
    NSUInteger key;
    perform_block_after_delay_k(kBetSyncWaitTime, &key, ^{
        match.editableObject.betSyncing = YES;
        NSMutableDictionary *parameters = [NSMutableDictionary new];
        parameters[@"bid"] = bid;
        parameters[@"result"] = MatchResultToString(result);
        parameters[kFTRequestParamResourcePathObject] = match;
        [self createWithParameters:parameters success:^(Bet *bet) {
            bet.match = match.editableObject;
            bet.user = [User currentUser];
            [[User currentUser] getWithSuccess:^(id response) {
                match.editableObject.betSyncing = NO;
                [match setBetTemporaryResult:0 value:nil];
                if (success) success(bet);
            } failure:failure];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (operation.response.statusCode == 500) {
                error = [NSError errorWithDomain:FootblAPIErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"Error: insufient funds", @"")}];
            }
            customFailureBlock(operation, error);
        }];
    });
    match.editableObject.betBlockKey = key;
}

+ (void)getWithObject:(User *)user success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    NSString *path = [NSString stringWithFormat:@"users/%@/bets", user.slug];
    [[FTOperationManager sharedManager] GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[self class] loadContent:responseObject inManagedObjectContext:[[self class] editableManagedObjectContext] usingCache:user.bets enumeratingObjectsWithBlock:^(Bet *bet, NSDictionary *data) {
            bet.user = user.editableObject;
        } untouchedObjectsBlock:^(NSSet *untouchedObjects) {
            [[self editableManagedObjectContext] deleteObjects:untouchedObjects];
        } completionBlock:success];
    } failure:failure];
}

#pragma mark - Instance Methods

- (void)updateWithBid:(NSNumber *)bid result:(MatchResult)result success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    FTOperationErrorBlock customFailureBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.match.editableObject setBetTemporaryResult:0 value:nil];
        self.match.editableObject.betSyncing = NO;
        if (failure) failure(operation, error);
    };
    
    [self.match.editableObject setBetTemporaryResult:result value:bid];
    
    if (self.match.betBlockKey) {
        cancel_block(self.match.betBlockKey);
    }
    
    NSUInteger key;
    perform_block_after_delay_k(kBetSyncWaitTime, &key, ^{
        self.match.editableObject.betSyncing = YES;

        NSMutableDictionary *parameters = [NSMutableDictionary new];
        parameters[@"result"] = MatchResultToString(result);
        parameters[@"bid"] = bid;
        parameters[kFTRequestParamResourcePathObject] = self.match;
        
        [self updateWithParameters:parameters success:^(id response) {
            [[[self class] editableManagedObjectContext] performBlock:^{
               self.match.editableObject.localUpdatedAt = [NSDate date];
                [[User currentUser] getWithSuccess:^(id response) {
                    self.match.editableObject.betSyncing = NO;
                    [self.match.editableObject setBetTemporaryResult:0 value:nil];
                    [[[self class] editableManagedObjectContext] performSave];
                    if (success) success(self);
                } failure:failure];
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (operation.response.statusCode == 500) {
                error = [NSError errorWithDomain:FootblAPIErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"Error: insufient funds", @"")}];
            }
            customFailureBlock(operation, error);
        }];
    });
    self.match.editableObject.betBlockKey = key;
}

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    self.match = [Match findWithObject:data[@"match"] inContext:self.managedObjectContext];
    self.value = data[@"bid"];
    self.result = @(MatchResultFromString(data[@"result"]));
}

- (void)deleteWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    FTOperationErrorBlock customFailureBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.match.editableObject setBetTemporaryResult:0 value:nil];
        self.match.editableObject.betSyncing = NO;
        if (failure) failure(operation, error);
    };
    
    Match *match = self.match.editableObject;
    [self.match.editableObject setBetTemporaryResult:0 value:@0];
    
    if (self.match.betBlockKey) {
        cancel_block(self.match.betBlockKey);
    }
    
    NSUInteger key;
    perform_block_after_delay_k(kBetSyncWaitTime, &key, ^{
        self.match.editableObject.betSyncing = YES;

        [self deleteWithSuccess:^(id response) {
            [[User currentUser] getWithSuccess:^(id response) {
                [match setBetTemporaryResult:0 value:nil];
                match.betSyncing = NO;
                if (success) success(nil);
            } failure:failure];
        } failure:customFailureBlock];
    });
    self.match.editableObject.betBlockKey = key;
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
