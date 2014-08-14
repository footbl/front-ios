//
//  CreditRequest.m
//  Footbl
//
//  Created by Fernando Saragoça on 8/14/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "CreditRequest.h"
#import "User.h"

#pragma mark CreditRequest

@implementation CreditRequest

#pragma mark - Class Methods

+ (NSArray *)enabledProperties {
    return [[super enabledProperties] arrayByAddingObjectsFromArray:@[@"payed", @"value"]];
}

+ (NSString *)resourcePath {
    return @"credit-requests";
}

#pragma mark - Instance Methods

- (NSString *)resourcePath {
    return [[[self class] resourcePathWithObject:self.creditedUser] stringByAppendingPathComponent:self.slug];
}

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    self.chargedUser = [User findOrCreateWithObject:data[@"chargedUser"] inContext:self.managedObjectContext];
    self.creditedUser = [User findOrCreateWithObject:data[@"creditedUser"] inContext:self.managedObjectContext];
}

@end
