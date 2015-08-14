
//
//  FTBPrize.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBPrize.h"
#import "FTBUser.h"

@implementation FTBPrize

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	NSDictionary *keyPaths = @{@"user": @"user",
							   @"value": @"value",
							   @"type": @"type",
							   @"seenBy": @"seenBy"};
	return [[super JSONKeyPathsByPropertyKey]mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}

+ (NSValueTransformer *)userJSONTransformer {
	return [MTLJSONAdapter dictionaryTransformerWithModelClass:[FTBUser class]];
}

+ (NSValueTransformer *)typeJSONTransformer {
	NSDictionary *dictionary = @{@"daily": @(FTBPrizeTypeDaily),
								 @"update": @(FTBPrizeTypeUpdate)};
	return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:dictionary];
}

+ (NSValueTransformer *)seenByJSONTransformer {
	return [MTLJSONAdapter arrayTransformerWithModelClass:[FTBUser class]];
}

@end
