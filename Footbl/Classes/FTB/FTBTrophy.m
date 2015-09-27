//
//  FTBTrophy.m
//  Footbl
//
//  Created by Leonardo Formaggio on 9/9/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBTrophy.h"

@implementation FTBTrophy

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{@"title": @"title",
			 @"subtitle": @"subtitle",
			 @"imageName": @"imageName",
			 @"progress": @"progress",
			 @"progressive": @"progressive"};
}

@end
