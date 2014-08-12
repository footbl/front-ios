//
//  Championship.h
//  Footbl
//
//  Created by Fernando Saragoça on 3/26/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "_Championship.h"

@class Wallet;

@interface Championship : _Championship

- (NSNumber *)pendingRounds;
- (NSString *)displayName;
- (NSString *)displayCountry;

@end
