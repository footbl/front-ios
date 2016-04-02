//
//  FTBGroup.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBGroup.h"
#import "FTBUser.h"
#import "FTBConstants.h"
#import "UIImage+Text.h"

@implementation FTBGroup

- (NSString *)sharingText {
    return [NSString stringWithFormat:NSLocalizedString(@"Join my group on Footbl! http://footbl.co/dl", @"")];
}

- (UIImage *)iconImage {
    UIImage *image = nil;
    if (self.type == FTBGroupTypeWorld) {
        image = [UIImage imageNamed:@"world_icon"];
    } else if (self.type == FTBGroupTypeFriends) {
        image = [UIImage imageNamed:@"icon-group-friends"];
    } else {
        NSString *code = [[FTBUser currentUser] ISOCountryCode];
        image = [UIImage imageWithText:code size:CGSizeMake(60, 60)] ?: [UIImage imageNamed:@"generic_group"];
    }
    return image;
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
