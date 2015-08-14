//
//  Team.h
//  Footbl
//
//  Created by Fernando Saragoça on 3/26/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "_Team.h"

@interface Team : _Team

- (NSString *)displayName;
- (NSURL *)pictureURL;
- (void)updateWithData:(NSDictionary *)data;

@end
