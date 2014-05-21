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

@synthesize betSyncing = _betSyncing;
@synthesize tempBetResult = _tempBetResult;
@synthesize tempBetValue = _tempBetValue;
@synthesize betBlockKey = _betBlockKey;

#pragma mark - Class Methods

+ (NSString *)resourcePath {
    SPLogError(@"Match resource path should not be used.");
    return @"championships/%@/matches";
}

+ (void)updateFromChampionship:(Championship *)championship success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    NSString *key = [NSString stringWithFormat:@"%@%@", championship.rid, API_DICTIONARY_KEY];
    [[self API] groupOperationsWithKey:key block:^{
        [[self API] ensureAuthenticationWithSuccess:^{
            NSMutableDictionary *parameters = [self generateParametersWithPage:API_CURRENT_PAGE(key)];
            [[self API] GET:[NSString stringWithFormat:@"championships/%@/matches", championship.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                API_APPEND_RESULT(responseObject, key);
                if ([[operation responseObject] count] == [self responseLimit]) {
                    API_APPEND_PAGE(key);
                    [FootblAPI performOperationWithoutGrouping:^{
                       [self updateFromChampionship:championship success:success failure:failure];
                    }];
                } else {
                    [self loadContent:API_RESULT(key) inManagedObjectContext:self.editableManagedObjectContext usingCache:championship.matches enumeratingObjectsWithBlock:^(Match *object, NSDictionary *contentEntry) {
                        object.championship = championship;
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

#pragma mark - Instance Methods

- (void)setBetBlockKey:(NSUInteger)betBlockKey {
    _betBlockKey = betBlockKey;
    
    if (self.managedObjectContext != FootblManagedObjectContext()) {
        [(Match *)[FootblManagedObjectContext() objectWithID:self.objectID] setBetBlockKey:betBlockKey];
    }
}

- (void)setBetSyncing:(BOOL)betSyncing {
    _betSyncing = betSyncing;
    
    if (self.managedObjectContext != FootblManagedObjectContext()) {
        [(Match *)[FootblManagedObjectContext() objectWithID:self.objectID] setBetSyncing:betSyncing];
    }
}

- (void)setBetTemporaryResult:(MatchResult)result value:(NSNumber *)value {
    if (self.managedObjectContext != FootblManagedObjectContext()) {
        [(Match *)[FootblManagedObjectContext() objectWithID:self.objectID] setBetTemporaryResult:result value:value];
    }
    self.tempBetResult = result;
    self.tempBetValue = value;
    
    if (value && ![self.championship.wallet.pendingMatchesToSyncBet containsObject:self]) {
        [self.championship.wallet.pendingMatchesToSyncBet addObject:self];
    } else if (!value) {
        [self.championship.wallet.pendingMatchesToSyncBet removeObject:self];
    }
}

- (NSString *)resourcePath {
    return [NSString stringWithFormat:@"championships/%@/matches", self.championship.rid];
}

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    if ([data[@"guest"] isKindOfClass:[NSDictionary class]]) {
        self.guest = [Team findOrCreateByIdentifier:data[@"guest"][kAPIIdentifierKey] inManagedObjectContext:self.managedObjectContext];
        self.host = [Team findOrCreateByIdentifier:data[@"host"][kAPIIdentifierKey] inManagedObjectContext:self.managedObjectContext];
        [self.guest updateWithData:data[@"guest"]];
        [self.host updateWithData:data[@"host"]];
    } else {
        self.guest = [Team findByIdentifier:data[@"guest"] inManagedObjectContext:self.managedObjectContext];
        self.host = [Team findByIdentifier:data[@"host"] inManagedObjectContext:self.managedObjectContext];
    }
    
    self.finished = data[@"finished"];
    self.hostScore = data[@"result"][@"host"];
    self.guestScore = data[@"result"][@"guest"];
    self.potDraw = data[@"pot"][@"draw"];
    self.potGuest = data[@"pot"][@"guest"];
    self.potHost = data[@"pot"][@"host"];
    self.round = data[@"round"];
    self.jackpot = data[@"jackpot"];
    
    if ([data[@"elapsed"] isKindOfClass:[NSNumber class]]) {
        self.elapsed = data[@"elapsed"];
    } else {
        self.elapsed = nil;
    }
    
    NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName];
    self.date = [transformer reverseTransformedValue:data[@"date"]];
}

@end
