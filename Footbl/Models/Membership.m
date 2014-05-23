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
    if ([data[@"rounds"] count] > 0) {
        NSDictionary *lastRound = [data[@"rounds"] lastObject];
        if ([lastRound[@"ranking"] isKindOfClass:[NSNumber class]]) {
            self.ranking = lastRound[@"ranking"];
        }
    }
    
    if (data[@"funds"] && [data[@"funds"] isKindOfClass:[NSNull class]]) {
        self.funds = nil;
    } else {
        self.funds = data[@"funds"];
    }
    
    self.hasRanking = @(self.ranking != nil);
    
    self.user = [User findOrCreateByIdentifier:data[@"user"][kAPIIdentifierKey] inManagedObjectContext:self.managedObjectContext];
    [self.user updateWithData:data[@"user"]];
}

@end
