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

- (NSString *)displayName {
    if (self.acronym && self.acronym.length > 0) {
        return self.acronym;
    }
    
    return self.name;
}

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    self.name = data[@"name"];
    self.picture = data[@"picture"];
    self.acronym = data[@"acronym"];
}

@end
