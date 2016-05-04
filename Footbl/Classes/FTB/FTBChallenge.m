//
//  FTBChallenge.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBChallenge.h"
#import "FTBUser.h"

@implementation FTBChallenge

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	NSDictionary *keyPaths = @{@"challengerUser": @"challenger.user",
							   @"challengedUser": @"challenged.user",
							   @"challengerResult": @"challenger.result",
							   @"challengedResult": @"challenged.result",
							   @"match": @"match",
							   @"bid": @"bid",
							   @"accepted": @"accepted"};
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}

+ (NSValueTransformer *)challengerUserJSONTransformer {
	return [MTLJSONAdapter dictionaryTransformerWithModelClass:[FTBUser class]];
}

+ (NSValueTransformer *)challengedUserJSONTransformer {
	return [MTLJSONAdapter dictionaryTransformerWithModelClass:[FTBUser class]];
}

+ (NSValueTransformer *)challengerResultJSONTransformer {
	return [FTBMatch resultJSONTransformer];
}

+ (NSValueTransformer *)challengedResultJSONTransformer {
	return [FTBMatch resultJSONTransformer];
}

+ (NSValueTransformer *)matchJSONTransformer {
	return [MTLJSONAdapter dictionaryTransformerWithModelClass:[FTBMatch class]];
}

- (BOOL)isEqual:(FTBChallenge *)object {
    if (self.identifier.length > 0) {
        return [super isEqual:object];
    } else {
        return [object isKindOfClass:[FTBChallenge class]] && [object.match isEqual:self.match];
    }
}

- (NSUInteger)hash {
    if (self.identifier.length > 0) {
        return [super hash];
    } else {
        return self.match.hash;
    }
}

@end
