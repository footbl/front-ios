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

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    self.name = data[@"name"];
    self.country = data[@"country"];
    if ([data[@"edition"] isKindOfClass:[NSNumber class]]) {
        self.edition = data[@"edition"];
    } else {
        self.edition = nil;
    }
    self.active = data[@"active"];
    self.currentRound = data[@"currentRound"];
    self.roundFinished = data[@"roundFinished"];
    self.rounds = data[@"rounds"];
    
    if (self.activeValue) {
        Group *group = [Group findOrCreateByIdentifier:self.rid inManagedObjectContext:self.managedObjectContext];
        group.championship = self;
        group.name = self.name;
        group.freeToEdit = @NO;
        group.owner = nil;
        group.isDefault = @YES;
    }
    
    [Team loadContent:data[@"competitors"] inManagedObjectContext:self.editableManagedObjectContext usingCache:self.competitors enumeratingObjectsWithBlock:^(Team *object, NSDictionary *contentEntry) {
        [object addChampionshipsObject:self];
    } deletingUntouchedObjectsWithBlock:^(NSSet *untouchedObjects) {
        [untouchedObjects makeObjectsPerformSelector:@selector(removeChampionshipsObject:) withObject:self];
    }];
}

@end
