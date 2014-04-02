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

+ (void)updateFromChampionship:(Championship *)championship success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [[self API] GET:[NSString stringWithFormat:@"championships/%@/matches", championship.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self loadContent:responseObject inManagedObjectContext:FootblBackgroundManagedObjectContext() usingCache:championship.matches enumeratingObjectsWithBlock:^(Match *object, NSDictionary *contentEntry) {
                object.championship = championship;
            } deletingUntouchedObjectsWithBlock:^(NSSet *untouchedObjects) {
                [FootblBackgroundManagedObjectContext() deleteObjects:untouchedObjects];
            }];
            requestSucceedWithBlock(responseObject, success);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           requestFailedWithBlock(operation, parameters, error, failure); 
        }];
    } failure:failure];
}

+ (void)updateBetsWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [[self API] GET:[NSString stringWithFormat:@"users/%@/bets", [[self API] userIdentifier]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [FootblBackgroundManagedObjectContext() performBlock:^{
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Match"];
                fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"rid" ascending:YES]];
                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"rid IN %@", [responseObject valueForKeyPath:@"match"]];
                NSError *error = nil;
                NSArray *fetchResult = [FootblBackgroundManagedObjectContext() executeFetchRequest:fetchRequest error:&error];
                if (error) {
                    SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
                for (NSDictionary *entry in responseObject) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rid = %@", [entry objectForKey:@"match"]];
                    Match *match = [fetchResult filteredArrayUsingPredicate:predicate].firstObject;
                    if (!match) {
                        continue;
                    }
                    match.bidValue = [entry objectForKey:@"bid"];
                    match.bidRid = [entry objectForKey:kAPIIdentifierKey];
                    match.bidResult = @(MatchResultFromString([entry objectForKey:@"result"]));
                    match.bidReward = [entry objectForKey:@"reward"];
                }
            }];
            SaveManagedObjectContext(FootblBackgroundManagedObjectContext());
            requestSucceedWithBlock(responseObject, success);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

#pragma mark - Instance Methods

- (void)updateWithData:(NSDictionary *)data {
    self.guest = [Team findOrCreateByIdentifier:[[data objectForKey:@"guest"] objectForKey:kAPIIdentifierKey] inManagedObjectContext:self.managedObjectContext];
    [self.guest updateWithData:[data objectForKey:@"guest"]];
    self.host = [Team findOrCreateByIdentifier:[[data objectForKey:@"host"] objectForKey:kAPIIdentifierKey] inManagedObjectContext:self.managedObjectContext];
    [self.host updateWithData:[data objectForKey:@"host"]];
    
    self.finished = [data objectForKey:@"finished"];
    self.hostScore = [[data objectForKey:@"result"] objectForKey:@"host"];
    self.guestScore = [[data objectForKey:@"result"] objectForKey:@"guest"];
    self.potDraw = [[data objectForKey:@"pot"] objectForKey:@"draw"];
    self.potGuest = [[data objectForKey:@"pot"] objectForKey:@"guest"];
    self.potHost = [[data objectForKey:@"pot"] objectForKey:@"host"];
    
    NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName];
    self.date = [transformer reverseTransformedValue:[data objectForKey:@"date"]];
}

- (void)updateWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [[self API] GET:[NSString stringWithFormat:@"championships/%@/matches/%@", self.championship.rid, self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self updateWithData:responseObject];
            SaveManagedObjectContext(FootblBackgroundManagedObjectContext());
            requestSucceedWithBlock(responseObject, success);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

- (void)updateBetWithBid:(NSNumber *)bid result:(MatchResult)result success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [self deleteBetWithSuccess:^{
        [[self API] ensureAuthenticationWithSuccess:^{
            NSMutableDictionary *parameters = [self generateDefaultParameters];
            NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName];
            [parameters setObject:[transformer transformedValue:[NSDate date]] forKey:@"date"];
            [parameters setObject:MatchResultToString(result) forKey:@"result"];
            [parameters setObject:bid forKey:@"bid"];
            [[self API] POST:[NSString stringWithFormat:@"championships/%@/matches/%@/bets", self.championship.rid, self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                self.bidResult = @(MatchResultFromString([responseObject objectForKey:@"result"]));
                self.bidRid = [responseObject objectForKey:kAPIIdentifierKey];
                self.bidReward = [responseObject objectForKey:@"reward"];
                self.bidValue = bid;
                SPLogVerbose(@"%@", responseObject);
                [self updateWithSuccess:success failure:failure];
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
            self.bidRid = nil;
            SaveManagedObjectContext(self.managedObjectContext);
            requestSucceedWithBlock(responseObject, success);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

@end
