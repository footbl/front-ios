//
//  FTBSeason.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBSeason.h"

@implementation FTBSeason

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	NSDictionary *keyPaths = @{@"sponsor": @"sponsor",
							   @"gift": @"gift",
							   @"finishAt": @"finishAt"};
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}

+ (NSValueTransformer *)finishAtJSONTransformer {
	return [super dateJSONTransformer];
}

@end
