//
//  FTBBet.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBBet.h"
#import "FTBUser.h"

@implementation FTBBet

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	NSDictionary *keyPaths = @{@"user": @"user",
							   @"match": @"match",
							   @"bid": @"bid",
							   @"result": @"result"};
	return [[super JSONKeyPathsByPropertyKey]mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}

+ (NSValueTransformer *)userJSONTransformer {
	return [MTLJSONAdapter dictionaryTransformerWithModelClass:[FTBUser class]];
}

+ (NSValueTransformer *)matchJSONTransformer {
	return [MTLJSONAdapter dictionaryTransformerWithModelClass:[FTBMatch class]];
}

+ (NSValueTransformer *)resultJSONTransformer {
	return [FTBMatch resultJSONTransformer];
}

@end
