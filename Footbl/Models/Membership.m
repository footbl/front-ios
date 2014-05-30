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
    if ([data[@"rounds"] count] > 0) {
        NSDictionary *lastRound = [data[@"rounds"] lastObject];
        if ([lastRound[@"ranking"] isKindOfClass:[NSNumber class]]) {
            self.ranking = lastRound[@"ranking"];
        }
        if ([lastRound[@"funds"] isKindOfClass:[NSNumber class]]) {
            self.funds = lastRound[@"funds"];
        }
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
