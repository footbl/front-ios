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

+ (NSArray *)enabledProperties {
    return [[super enabledProperties] arrayByAddingObjectsFromArray:@[@"country", @"currentRound", @"edition", @"name", @"picture", @"rounds"]];
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

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    NSString *string = [NSString stringWithFormat:@"Championship: %@", self.name];
    if ([NSLocalizedString(string, @"") isEqualToString:string]) {
        self.displayName = self.name;
    } else {
        self.displayName = NSLocalizedString(string, @"");
    }
    self.typeString = data[@"type"];
    self.enabledValue = self.entry ? YES : NO;
}

@end
