//
//  FTBBet.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBBet.h"
#import "FTBUser.h"
#import "FTBMatch.h"

@implementation FTBBet

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	NSDictionary *keyPaths = @{@"user": @"user",
							   @"match": @"match",
							   @"bid": @"bid",
							   @"result": @"result"};
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}

+ (NSValueTransformer *)resultJSONTransformer {
	return [FTBMatch resultJSONTransformer];
}

+ (NSValueTransformer *)userJSONTransformer {
	return [MTLJSONAdapter dictionaryTransformerWithModelClass:[FTBUser class]];
}

+ (NSValueTransformer *)matchJSONTransformer {
	return [MTLJSONAdapter dictionaryTransformerWithModelClass:[FTBMatch class]];
}

- (NSString *)valueString {
	return @"0";
}

- (NSNumber *)toReturn {
	return @0;
}

- (NSString *)toReturnString {
	return @"0";
}

- (NSNumber *)reward {
	return @0;
}

- (NSString *)rewardString {
	return @"0";
}

@end
