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
    if ([[data objectForKey:@"ranking"] isKindOfClass:[NSNull class]]) {
        self.ranking = @(0);
    } else {
        self.ranking = [data objectForKey:@"ranking"];
    }
    self.user = [User findOrCreateByIdentifier:[data objectForKey:@"user"] inManagedObjectContext:self.managedObjectContext];
}

@end
