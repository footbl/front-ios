//
//  FTBCreditRequest.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBCreditRequest.h"
#import "FTBUser.h"

@implementation FTBCreditRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	NSDictionary *keyPaths = @{@"creditedUser": @"creditedUser",
							   @"chargedUser": @"chargedUser",
							   @"value": @"value",
							   @"payed": @"payed"};
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}

+ (NSValueTransformer *)creditedUserJSONTransformer {
	return [MTLJSONAdapter dictionaryTransformerWithModelClass:[FTBUser class]];
}

+ (NSValueTransformer *)chargedUserJSONTransformer {
	return [MTLJSONAdapter dictionaryTransformerWithModelClass:[FTBUser class]];
}

@end
