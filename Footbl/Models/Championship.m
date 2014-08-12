//
//  Championship.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/26/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "AppDelegate.h"
#import "Championship.h"

@interface Championship ()

@end

#pragma mark Championship

@implementation Championship

#pragma mark - Class Methods

+ (NSString *)resourcePath {
    return @"championships";
}

#pragma mark - Instance Methods

- (NSNumber *)pendingRounds {
    return @(self.roundsValue - (self.currentRoundValue - 1));
}

- (NSString *)displayCountry {
    NSString *string = [NSString stringWithFormat:@"Country: %@", self.country];
    if ([NSLocalizedString(string, @"") isEqualToString:string]) {
        return self.country;
    }
    return NSLocalizedString(string, @"");
}

- (NSString *)displayName {
    NSString *string = [NSString stringWithFormat:@"Championship: %@", self.name];
    if ([NSLocalizedString(string, @"") isEqualToString:string]) {
        return self.name;
    }
    return NSLocalizedString(string, @"");
}

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
}

@end
