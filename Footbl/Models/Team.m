//
//  Team.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/26/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "Team.h"

@interface Team ()

@end

#pragma mark Team

@implementation Team

#pragma mark - Class Methods

#pragma mark - Instance Methods

- (void)updateWithData:(NSDictionary *)data {
    self.name = data[@"name"];
    self.picture = data[@"picture"];
}

@end
