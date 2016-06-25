//
//  FTBChallenge.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBChallenge.h"
#import "FTBUser.h"
#import "NSNumber+Formatter.h"

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

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self) {
        self.waiting = !dictionaryValue[@"accepted"];
    }
    return self;
}

- (NSString *)valueString {
    return self.bid.integerValue == 0 ? @"-" : self.bid.walletStringValue;
}

- (NSNumber *)toReturn {
    switch (self.challengerResult) {
        case FTBMatchResultHost:
            return @(self.bid.integerValue * 2);
        case FTBMatchResultDraw:
            return @(self.bid.integerValue * 2);
        case FTBMatchResultGuest:
            return @(self.bid.integerValue * 2);
        default:
            return @0;
    }
}

- (NSString *)toReturnString {
    return self.bid.integerValue == 0 ? @"-" : self.toReturn.walletStringValue;
}

- (NSNumber *)reward {
    if (self.bid.integerValue == 0 || self.match.status == FTBMatchStatusWaiting) {
        return @0;
    }

    if (self.myResult == self.match.result) {
        return @(self.toReturn.floatValue - self.bid.integerValue);
    } else {
        return @(-self.bid.integerValue);
    }
}

- (NSString *)rewardString {
    if (self.bid.integerValue == 0 || self.match.status == FTBMatchStatusWaiting) {
        return @"-";
    }
    return @(nearbyint(self.reward.doubleValue)).walletStringValue;
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

- (FTBUser *)me {
    if ([self.challengedUser isEqual:[FTBUser currentUser]]) {
        return self.challengedUser;
    }

    if ([self.challengerUser isEqual:[FTBUser currentUser]]) {
        return self.challengerUser;
    }

    return nil;
}

- (FTBUser *)oponent {
    if (![self.challengedUser isEqual:[FTBUser currentUser]]) {
        return self.challengedUser;
    }

    if (![self.challengerUser isEqual:[FTBUser currentUser]]) {
        return self.challengerUser;
    }

    return nil;
}

- (FTBMatchResult)myResult {
    if ([self.challengedUser isEqual:[FTBUser currentUser]]) {
        return self.challengedResult;
    }

    if ([self.challengerUser isEqual:[FTBUser currentUser]]) {
        return self.challengerResult;
    }

    return FTBMatchResultUnknown;
}

- (FTBMatchResult)oponentResult {
    if (![self.challengedUser isEqual:[FTBUser currentUser]]) {
        return self.challengedResult;
    }

    if (![self.challengerUser isEqual:[FTBUser currentUser]]) {
        return self.challengerResult;
    }

    return FTBMatchResultUnknown;
}

@end
