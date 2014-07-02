//
//  Membership.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/04/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "Membership.h"
#import "User.h"

@interface Membership ()

@end


@implementation Membership

#pragma mark - Class Methods

#pragma mark - Instance Methods

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    self.ranking = nil;
    self.funds = nil;
    
    NSArray *rounds = data[@"rounds"];
    NSMutableArray *lastRounds = [NSMutableArray new];
    for (NSInteger i = 1; i <= 12 && i < rounds.count; i++) {
        NSDictionary *currentRound = rounds[rounds.count - i];
        if ([currentRound[@"ranking"] isKindOfClass:[NSNumber class]]) {
            [lastRounds addObject:@{@"ranking" : currentRound[@"ranking"], @"funds" : currentRound[@"funds"]}];
        } else {
            [lastRounds addObject:@{@"funds" : currentRound[@"funds"]}];
        }
    }
    
    self.ranking = lastRounds.firstObject[@"ranking"];
    self.funds = lastRounds.firstObject[@"funds"];
    self.lastRounds = lastRounds;
    
    if (!self.funds) {
        self.funds = data[@"initialFunds"];
    }
    
    self.hasRanking = @(self.ranking != nil);
    
    if ([data[@"user"] isKindOfClass:[NSDictionary class]]) {
        self.user = [User findOrCreateByIdentifier:data[@"user"][kAPIIdentifierKey] inManagedObjectContext:self.managedObjectContext];
        [self.user updateWithData:data[@"user"]];
    } else {
        self.user = nil;
    }
}

@end
