//
//  Match.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/26/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <TransformerKit/TransformerKit.h>
#import "Championship.h"
#import "Match.h"
#import "Team.h"
#import "Wallet.h"

extern NSString * MatchResultToString(MatchResult result) {
    switch (result) {
        case MatchResultDraw:
            return @"draw";
        case MatchResultGuest:
            return @"guest";
        case MatchResultHost:
            return @"host";
    }
}

extern MatchResult MatchResultFromString(NSString *result) {
    if ([result.lowercaseString isEqualToString:@"guest"]) {
        return MatchResultGuest;
    } else if ([result.lowercaseString isEqualToString:@"host"]) {
        return MatchResultHost;
    } else {
        return MatchResultDraw;
    }
}

@interface Match ()

@end

#pragma mark Match

@implementation Match

#pragma mark - Class Methods

+ (NSString *)resourcePath {
    SPLogError(@"Match resource path should not be used.");
    return @"championships/%@/matches";
}

+ (void)updateFromChampionship:(Championship *)championship success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [[self API] GET:[NSString stringWithFormat:@"championships/%@/matches", championship.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self loadContent:responseObject inManagedObjectContext:self.editableManagedObjectContext usingCache:championship.matches enumeratingObjectsWithBlock:^(Match *object, NSDictionary *contentEntry) {
                object.championship = championship;
            } deletingUntouchedObjectsWithBlock:^(NSSet *untouchedObjects) {
                [self.editableManagedObjectContext deleteObjects:untouchedObjects];
            }];
            requestSucceedWithBlock(operation, parameters, success);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           requestFailedWithBlock(operation, parameters, error, failure); 
        }];
    } failure:failure];
}

+ (void)updateBetsFromChampionship:(Championship *)championship success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [[self API] GET:[NSString stringWithFormat:@"wallets/%@/bets", championship.wallet.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.editableManagedObjectContext performBlock:^{
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Match"];
                fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"rid" ascending:YES]];
                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"rid IN %@", [responseObject valueForKeyPath:[NSString stringWithFormat:@"match.%@", kAPIIdentifierKey]]];
                NSError *error = nil;
                NSArray *fetchResult = [self.editableManagedObjectContext executeFetchRequest:fetchRequest error:&error];
                if (error) {
                    SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
                for (NSDictionary *entry in responseObject) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rid = %@", entry[@"match"][kAPIIdentifierKey]];
                    Match *match = [fetchResult filteredArrayUsingPredicate:predicate].firstObject;
                    if (!match) {
                        continue;
                    }
                    match.bidValue = entry[@"bid"];
                    match.bidRid = entry[kAPIIdentifierKey];
                    match.bidResult = @(MatchResultFromString(entry[@"result"]));
                    match.bidReward = entry[@"reward"];
                }
                SaveManagedObjectContext(self.editableManagedObjectContext);
                requestSucceedWithBlock(operation, parameters, success);
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

#pragma mark - Instance Methods

- (NSString *)resourcePath {
    return [NSString stringWithFormat:@"championships/%@/matches", self.championship.rid];
}

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    self.guest = [Team findOrCreateByIdentifier:data[@"guest"][kAPIIdentifierKey] inManagedObjectContext:self.managedObjectContext];
    [self.guest updateWithData:data[@"guest"]];
    self.host = [Team findOrCreateByIdentifier:data[@"host"][kAPIIdentifierKey] inManagedObjectContext:self.managedObjectContext];
    [self.host updateWithData:data[@"host"]];
    
    self.finished = data[@"finished"];
    self.hostScore = data[@"result"][@"host"];
    self.guestScore = data[@"result"][@"guest"];
    self.potDraw = data[@"pot"][@"draw"];
    self.potGuest = data[@"pot"][@"guest"];
    self.potHost = data[@"pot"][@"host"];
    self.round = data[@"round"];
    
    NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName];
    self.date = [transformer reverseTransformedValue:data[@"date"]];
}

- (void)updateBetWithBid:(NSNumber *)bid result:(MatchResult)result success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [self deleteBetWithSuccess:^{
        [[self API] ensureAuthenticationWithSuccess:^{
            NSMutableDictionary *parameters = [self generateDefaultParameters];
            NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName];
            parameters[@"date"] = [transformer transformedValue:[NSDate date]];
            parameters[@"result"] = MatchResultToString(result);
            parameters[@"bid"] = bid;
            [[self API] POST:[NSString stringWithFormat:@"championships/%@/matches/%@/bets", self.championship.rid, self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self.editableManagedObjectContext performBlock:^{
                    self.bidResult = @(MatchResultFromString(responseObject[@"result"]));
                    self.bidRid = responseObject[kAPIIdentifierKey];
                    self.bidReward = responseObject[@"reward"];
                    self.bidValue = bid;
                    SaveManagedObjectContext(self.editableManagedObjectContext);
                    requestSucceedWithBlock(operation, parameters, success);
                }];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                requestFailedWithBlock(operation, parameters, error, failure);
            }];
        } failure:failure];
    } failure:failure];
}

- (void)deleteBetWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    if (!self.bidRid) {
        if (success) success();
        return;
    }
    
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [[self API] DELETE:[NSString stringWithFormat:@"championships/%@/matches/%@/bets/%@", self.championship.rid, self.rid, self.bidRid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.editableManagedObjectContext performBlock:^{
                self.bidRid = nil;
                SaveManagedObjectContext(self.editableManagedObjectContext);
                requestSucceedWithBlock(operation, parameters, success);
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

@end
