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
    
    if ([data[@"ranking"] isKindOfClass:[NSNull class]]) {
        self.ranking = nil;
    } else {
        self.ranking = data[@"ranking"];
    }
    if ([data[@"ranking"] isKindOfClass:[NSNull class]]) {
        self.funds = nil;
    } else {
        self.funds = data[@"funds"];
    }
    
    self.user = [User findOrCreateByIdentifier:data[@"user"][kAPIIdentifierKey] inManagedObjectContext:self.managedObjectContext];
    [self.user updateWithData:data[@"user"]];
}

@end
