//
//  User.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/04/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <CargoBay/CargoBay.h>
#import <RMStore/RMStore.h>
#import <TransformerKit/TransformerKit.h>
#import "Bet.h"
#import "Group.h"
#import "NSNumber+Formatter.h"
#import "User.h"

@interface User ()

@end

#pragma mark User

@implementation User

#pragma mark - Class Methods

+ (NSString *)resourcePath {
    return @"users";
}

+ (NSArray *)enabledProperties {
    return [[super enabledProperties] arrayByAddingObjectsFromArray:@[@"about", @"email", @"funds", @"history", @"name", @"picture", @"previousRanking",
                                                                      @"ranking", @"stake", @"username", @"verified"]];
}

+ (instancetype)currentUser {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"isMe = %@", @YES];
    fetchRequest.fetchLimit = 1;
    NSError *error = nil;
    NSArray *fetchResult = [[self editableManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (error) {
        SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    User *user = fetchResult.firstObject;
    if (!user) {
        user = [User findOrCreateWithObject:@"me" inContext:[self editableManagedObjectContext]];
        user.isMe = @YES;
    }
    return user;
}

+ (void)searchUsingEmails:(NSArray *)emails usernames:(NSArray *)usernames ids:(NSArray *)ids fbIds:(NSArray *)fbIds success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    if (emails) {
        parameters[@"emails"] = emails;
    }
    if (usernames) {
        parameters[@"usernames"] = usernames;
    }
    if (ids) {
        parameters[@"ids"] = ids;
    }
    if (fbIds) {
        parameters[@"facebookIds"] = fbIds;
    }
    
    [[FTOperationManager sharedManager] performOperationWithOptions:FTRequestOptionAutoPage | FTRequestOptionGroupRequests operations:^{
       [[FTOperationManager sharedManager] GET:@"users" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
           if (success) success(responseObject);
       } failure:failure];
    }];
}

+ (void)getMeWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[FTOperationManager sharedManager] GET:@"users/me" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[self editableManagedObjectContext] performBlock:^{
            User *user = [User findOrCreateWithObject:responseObject inContext:[self editableManagedObjectContext]];
            user.isMeValue = YES;
            [[self editableManagedObjectContext] performSave];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) success(user);
            });
        }];
    } failure:failure];
}

+ (void)getFeaturedWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[FTOperationManager sharedManager] GET:@"users" parameters:@{@"featured" : @YES} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self loadContent:responseObject inManagedObjectContext:[self editableManagedObjectContext] usingCache:nil enumeratingObjectsWithBlock:^(User *user, NSDictionary *data) {
            user.featured = @YES;
        } untouchedObjectsBlock:^(NSSet *untouchedObjects) {
            [untouchedObjects makeObjectsPerformSelector:@selector(setFeatured:) withObject:@NO];
        } completionBlock:success];
    } failure:failure];
}

#pragma mark - Getters/Setters

@synthesize pendingMatchesToSyncBet = _pendingMatchesToSyncBet;

- (NSMutableArray *)pendingMatchesToSyncBet {
    if (!_pendingMatchesToSyncBet) {
        _pendingMatchesToSyncBet = [NSMutableArray new];
    }
    return _pendingMatchesToSyncBet;
}

#pragma mark - Instance Methods

- (void)getWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [super getWithSuccess:^(id response) {
        /*
        [[FTOperationManager sharedManager] GET:[NSString stringWithFormat:@"users/%@/fans", self.rid] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.numberOfFans = @([responseObject count]);
        } failure:nil];
        
        [[FTOperationManager sharedManager] GET:[NSString stringWithFormat:@"users/%@/entries", self.rid] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.numberOfLeagues = @([responseObject count]);
        } failure:nil];
        */
        
        if (success) success(response);
    } failure:failure];
}

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    if (self.isMeValue) {
        Group *group = [Group findOrCreateWithObject:@"world" inContext:self.managedObjectContext];
        group.name = NSLocalizedString(@"World", @"");
        group.freeToEdit = @NO;
        group.owner = nil;
        group.isDefault = @YES;
        group.picture = nil;
    }
}

- (BOOL)isFanOfUser:(User *)user {
    return [self.fanByUsersSet filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"rid = %@", user.rid]].count > 0;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    if (self.email) {
        dictionary[@"email"] = self.email;
    }
    if (self.username) {
        dictionary[@"username"] = self.username;
    }
    if (self.name) {
        dictionary[@"name"] = self.name;
    }
    if (self.picture) {
        dictionary[@"picture"] = self.picture;
    }
    if (self.about) {
        dictionary[@"about"] = self.about;
    }
    return dictionary;
}

- (void)getStarredWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[FTOperationManager sharedManager] GET:[NSString stringWithFormat:@"users/%@/featured", self.rid] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[self class] loadContent:[responseObject valueForKeyPath:@"featured"] inManagedObjectContext:[[self class] editableManagedObjectContext] usingCache:nil enumeratingObjectsWithBlock:^(User *user, NSDictionary *data) {
            [self addFanOfUsersObject:user];
        } untouchedObjectsBlock:^(NSSet *untouchedObjects) {
            [self removeFanOfUsers:untouchedObjects];
        } completionBlock:success];
    } failure:failure];
}

- (void)getFansWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[FTOperationManager sharedManager] GET:[NSString stringWithFormat:@"users/%@/fans", self.rid] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[self class] loadContent:responseObject inManagedObjectContext:[[self class] editableManagedObjectContext] usingCache:nil enumeratingObjectsWithBlock:^(User *user, NSDictionary *data) {
            [self addFanByUsersObject:user];
        } untouchedObjectsBlock:^(NSSet *untouchedObjects) {
            [self removeFanByUsers:untouchedObjects];
        } completionBlock:success];
    } failure:failure];
}

- (void)starUser:(User *)user success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[[self class] editableManagedObjectContext] performBlock:^{
        [self addFanOfUsersObject:user];
        user.numberOfFans = @(MAX(user.editableObject.numberOfFansValue + 1, MAX_FOLLOWERS_COUNT));
        [[[self class] editableManagedObjectContext] performSave];
    }];
    
    [[FTOperationManager sharedManager] POST:[NSString stringWithFormat:@"users/%@/featured", self.rid] parameters:@{@"featured" : user.rid} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) success(user);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[[self class] editableManagedObjectContext] performBlock:^{
            [self removeFanOfUsersObject:user.editableObject];
            [[[self class] editableManagedObjectContext] performSave];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) failure(operation, error);
            });
        }];
    }];
}

- (void)unstarUser:(User *)user success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[[self class] editableManagedObjectContext] performBlock:^{
        [self removeFanOfUsersObject:user.editableObject];
        if (user.numberOfFansValue < MAX_FOLLOWERS_COUNT) {
            user.numberOfFans = @(MAX(0, user.editableObject.numberOfFansValue - 1));
        }
        [[[self class] editableManagedObjectContext] performSave];
    }];
    
    [[FTOperationManager sharedManager] DELETE:[NSString stringWithFormat:@"users/%@/featured/%@", self.rid, user.rid] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) success(user);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[[self class] editableManagedObjectContext] performBlock:^{
            [self addFanOfUsersObject:user.editableObject];
            [[[self class] editableManagedObjectContext] performSave];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) failure(operation, error);
            });
        }];
    }];
}

#pragma mark - Wallet

- (NSSet *)activeBets {
    return [self.bets filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"bid > %@ AND match.finished = %@", @0, @NO]];
}

- (BOOL)canRecharge {
    return (self.totalWallet.integerValue < 100);
}

- (NSNumber *)localFunds {
    NSInteger funds = self.funds.integerValue;
    if (self.isMeValue) {
        for (Bet *bet in self.activeBets) {
            funds += bet.bidValue;
            funds -= bet.match.myBetValue.floatValue;
        }
        for (Match *match in self.pendingMatchesToSyncBet) {
            if (!match.myBet) {
                funds -= match.myBetValue.floatValue;
            }
        }
    }
    
    if (FBTweakValue(@"Values", @"Profile", @"Wallet", 0, 0, HUGE_VAL)) {
        return @(FBTweakValue(@"Values", @"Profile", @"Wallet", 0, 0, HUGE_VAL));
    }
    
    return @(funds);
}

- (NSNumber *)localStake {
    NSInteger stake = 0;
    if (self.isMeValue) {
        for (Bet *bet in self.activeBets) {
            stake += bet.match.myBetValue.floatValue;
        }
        for (Match *match in self.pendingMatchesToSyncBet) {
            if (!match.myBet) {
                stake += match.myBetValue.floatValue;
            }
        }
    } else {
        stake = self.stakeValue;
    }
    
    if (FBTweakValue(@"Values", @"Profile", @"Stake", 0, 0, HUGE_VAL)) {
        return @(FBTweakValue(@"Values", @"Profile", @"Stake", 0, 0, HUGE_VAL));
    }
    
    return @(stake);
}

- (NSNumber *)toReturn {
    float toReturn = 0;
    if (self.isMeValue) {
        for (Bet *bet in self.activeBets) {
            toReturn += bet.match.myBetReturn.floatValue;
        }
        for (Match *match in self.pendingMatchesToSyncBet) {
            if (!match.myBet) {
                toReturn += match.myBetReturn.floatValue;
            }
        }
    } else {
        for (Bet *bet in self.activeBets) {
            toReturn += bet.toReturn.floatValue;
        }
    }
    
    if (FBTweakValue(@"Values", @"Profile", @"To Return", 0, 0, HUGE_VAL)) {
        return @(FBTweakValue(@"Values", @"Profile", @"To Return", 0, 0, HUGE_VAL));
    }
    
    return @(toReturn);
}

- (NSString *)toReturnString {
    return self.toReturn.integerValue > 0 ? @(nearbyintf(self.toReturn.floatValue)).limitedWalletStringValue : @"-";
}

- (NSNumber *)profit {
    float profit = 0;
    for (Bet *bet in self.activeBets) {
        profit += bet.reward.floatValue;
    }
    
    if (FBTweakValue(@"Values", @"Profile", @"Profit", 0, 0, HUGE_VAL)) {
        return @(FBTweakValue(@"Values", @"Profile", @"Profit", 0, 0, HUGE_VAL));
    }
    
    return @(profit);
}

- (NSString *)profitString {
    BOOL started = NO;
    for (Bet *bet in self.activeBets) {
        if (bet.match.status != MatchStatusWaiting) {
            started = YES;
            break;
        }
    }
    
    if (FBTweakValue(@"Values", @"Profile", @"Profit", 0, 0, HUGE_VAL)) {
        started = YES;
    }
    
    return started ? @(nearbyintf(self.profit.floatValue)).limitedWalletStringValue : @"-";
}

- (NSNumber *)totalWallet {
    return @(self.localFunds.floatValue + self.localStake.floatValue);
}

- (NSNumber *)highestWallet {
    NSDictionary *wallet = [self.history sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"funds" ascending:NO]]].firstObject;
    if (wallet) {
        return @(MAX(self.totalWallet.floatValue, [wallet[@"funds"] floatValue]));
    }
    
    return self.totalWallet;
}

- (NSDate *)highestWalletDate {
    NSDictionary *wallet = [self.history sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"funds" ascending:NO]]].firstObject;
    if (wallet && [wallet[@"funds"] floatValue] > self.totalWallet.floatValue) {
        NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName];
        return [transformer reverseTransformedValue:wallet[@"date"]];
    }
    
    return [NSDate date];
}

- (void)rechargeWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[RMStore defaultStore] requestProducts:[NSSet setWithArray:@[@"com.madeatsampa.Footbl.recharge"]] success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        SKProduct *product = products.firstObject;
        if (product) {
            [[RMStore defaultStore] addPayment:product.productIdentifier success:^(SKPaymentTransaction *transaction) {
                [[CargoBay sharedManager] verifyTransaction:transaction password:nil success:^(NSDictionary *receipt) {
                    NSMutableDictionary *parameters = [NSMutableDictionary new];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    parameters[@"receipt"] = CBBase64EncodedStringFromData(transaction.transactionReceipt);
#pragma clang diagnostic pop
                    [[FTOperationManager sharedManager] GET:[self.resourcePath stringByAppendingPathComponent:@"recharge"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        [self getWithSuccess:success failure:failure];
                    } failure:failure];
                } failure:^(NSError *error) {
                    if (failure) failure(nil, error);
                }];
            } failure:^(SKPaymentTransaction *transaction, NSError *error) {
                if (failure) failure(nil, error);
            }];
        } else {
            if (failure) failure(nil, nil);
        }
    } failure:^(NSError *error) {
        if (failure) failure(nil, error);
    }];
}

@end
