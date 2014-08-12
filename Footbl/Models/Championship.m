//
//  Championship.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/26/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "AppDelegate.h"
#import "Championship.h"
#import "Group.h"
#import "Team.h"
#import "User.h"

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
    if (!self.activeValue) {
        return @0;
    }
    
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

- (Wallet *)myWallet {
    return [self.wallets filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"user.rid = %@", [User currentUser].rid]].anyObject;
}

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    if (self.activeValue) {
        Group *group = [Group findOrCreateByIdentifier:self.rid inManagedObjectContext:self.managedObjectContext];
        group.championship = self;
        group.name = self.displayName;
        group.freeToEdit = @NO;
        group.owner = nil;
        group.isDefault = @YES;
        group.picture = self.picture;
    }
}

@end
