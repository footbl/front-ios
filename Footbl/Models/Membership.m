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

+ (NSString *)resourcePathWithObject:(FTModel *)object {
    return [[object.resourcePath stringByAppendingPathComponent:object.rid] stringByAppendingPathComponent:@"members"];
}

#pragma mark - Instance Methods

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    if ([data[@"user"] isKindOfClass:[NSDictionary class]]) {
        self.user = [User findOrCreateWithObject:data[@"user"] inContext:self.managedObjectContext];
    } else {
        self.user = nil;
    }
}

@end
