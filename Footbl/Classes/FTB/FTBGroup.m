//
//  FTBGroup.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBGroup.h"

@implementation FTBGroup

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	NSDictionary *keyPaths = @{@"name": @"name",
							   @"code": @"code",
							   @"owner": @"owner",
							   @"pictureURL": @"picture",
							   @"featured": @"featured",
							   @"invites": @"invites",
							   @"members": @"members"};
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}

@end
