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

- (BOOL)isWorld {
	return NO;
}

- (BOOL)isFriends {
	return NO;
}

- (BOOL)isDefault {
	return self.isWorld || self.isFriends;
}

- (NSString *)sharingText {
	if (self.isDefault) {
		return [NSString stringWithFormat:NSLocalizedString(@"Join my group on Footbl! http://footbl.co/dl", @"")];
	} else {
		NSString *sharingUrl = [NSString stringWithFormat:@"http://footbl.co/groups/%@", self.identifier];
		return [NSString stringWithFormat:NSLocalizedString(@"Join my group on Footbl! Access %@ or use the code %@", @"@{group_share_url} {group_code}"), sharingUrl, self.identifier];
	}
}

- (void)saveStatusInLocalDatabase {}

@end
