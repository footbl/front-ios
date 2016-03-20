//
//  FTBGroup.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBGroup.h"
#import "FTBUser.h"

@implementation FTBGroup

- (NSString *)sharingText {
    return [NSString stringWithFormat:NSLocalizedString(@"Join my group on Footbl! http://footbl.co/dl", @"")];
}

- (NSString *)name {
    switch (self.type) {
        case FTBGroupTypeCountry:
            return [[FTBUser currentUser] country];
        case FTBGroupTypeFriends:
            return NSLocalizedString(@"Friends", @"");
        case FTBGroupTypeWorld:
            return NSLocalizedString(@"World", @"");
        default:
            return @"";
    }
}

@end
