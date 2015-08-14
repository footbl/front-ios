//
//  FTBChampionship.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/11/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBChampionship.h"

@implementation FTBChampionship

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	NSDictionary *keyPaths = @{@"name": @"name",
							   @"pictureURL": @"picture",
							   @"type": @"type",
							   @"country": @"country"};
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}

+ (NSValueTransformer *)pictureURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)typeJSONTransformer {
	NSDictionary *dictionary = @{@"national league": @(FTBChampionshipTypeNationalLeague),
								 @"continental league": @(FTBChampionshipTypeContinentalLeague),
								 @"world cup": @(FTBChampionshipTypeWorldCup)};
	return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:dictionary];
}

@end
