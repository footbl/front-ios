//
//  Entry.m
//  Footbl
//
//  Created by Fernando Saragoça on 8/14/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "Championship.h"
#import "Entry.h"
#import "User.h"

#pragma mark Entry

@implementation Entry

#pragma mark - Class Methods

+ (NSString *)resourcePath {
    return @"entries";
}

#pragma mark - Instance Methods

- (NSString *)resourcePath {
    return [[self class] resourcePathWithObject:[User currentUser]];
}

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    self.championship = [Championship findOrCreateWithObject:data[@"championship"] inContext:self.managedObjectContext];
}

@end
