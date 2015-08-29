//
//  FTBMessage.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBMessage.h"
#import "FTBUser.h"

@implementation FTBMessage

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	NSDictionary *keyPaths = @{@"user": @"user",
							   @"room": @"room",
							   @"message": @"message",
							   @"type": @"type",
							   @"seenBy": @"seenBy"};
	return [[super JSONKeyPathsByPropertyKey]mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}

+ (NSValueTransformer *)userJSONTransformer {
	return [MTLJSONAdapter dictionaryTransformerWithModelClass:[FTBUser class]];
}

+ (NSValueTransformer *)roomJSONTransformer {
	return [MTLJSONAdapter dictionaryTransformerWithModelClass:[FTBModel class]];
}

+ (NSValueTransformer *)seenByJSONTransformer {
	return [MTLJSONAdapter arrayTransformerWithModelClass:[FTBUser class]];
}

- (BOOL)deliveryFailedValue {
	return NO;
}

@end
