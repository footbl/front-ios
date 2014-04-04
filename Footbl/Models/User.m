//
//  User.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/04/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "User.h"

@interface User ()

@end

#pragma mark User

@implementation User

#pragma mark - Class Methods

+ (instancetype)currentUser {
    return [[self API] currentUser];
}

#pragma mark - Instance Methods

- (void)updateWithData:(NSDictionary *)data {
    self.verified = [data objectForKey:@"verified"];
}

@end
