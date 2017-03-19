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

@interface FTBChallenge ()

@property (nonatomic) BOOL accepted;

@end

@implementation FTBChallenge

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	NSDictionary *keyPaths = @{@"sender": @"challenger.user",
							   @"recipient": @"challenged.user",
							   @"senderResult": @"challenger.result",
							   @"recipientResult": @"challenged.result",
							   @"match": @"match",
							   @"bid": @"bid",
							   @"accepted": @"accepted"};
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}

+ (NSValueTransformer *)senderJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[FTBUser class]];
}

+ (NSValueTransformer *)recipientJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[FTBUser class]];
}

+ (NSValueTransformer *)senderResultJSONTransformer {
    return [FTBMatch resultJSONTransformer];
}

+ (NSValueTransformer *)recipientResultJSONTransformer {
    return [FTBMatch resultJSONTransformer];
}

+ (NSValueTransformer *)matchJSONTransformer {
	return [MTLJSONAdapter dictionaryTransformerWithModelClass:[FTBMatch class]];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self) {
        if (dictionaryValue[@"accepted"]) {
            self.status = self.accepted ? FTBChallengeStatusAccepted : FTBChallengeStatusRejected;
        } else if (self.match.started) {
            self.status = FTBChallengeStatusRejected;
        } else {
            self.status = FTBChallengeStatusWaiting;
        }
    }
    return self;
}

- (NSString *)valueString {
    return self.bid.integerValue == 0 ? @"-" : self.bid.walletStringValue;
}

- (NSNumber *)toReturn {
    switch (self.senderResult) {
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
    } else if (self.oponentResult == self.match.result) {
        return @(-self.bid.integerValue);
    } else {
        return @0;
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
    if (self.recipient.isMe) {
        return self.recipient;
    }

    if (self.sender.isMe) {
        return self.sender;
    }

    return nil;
}

- (FTBUser *)oponent {
    if (self.recipient.isMe) {
        return self.sender;
    }

    if (self.sender.isMe) {
        return self.recipient;
    }

    return nil;
}

- (FTBMatchResult)myResult {
    if (self.recipient.isMe) {
        return self.recipientResult;
    }

    if (self.sender.isMe) {
        return self.senderResult;
    }

    return FTBMatchResultUnknown;
}

- (FTBMatchResult)oponentResult {
    if (self.recipient.isMe) {
        return self.senderResult;
    }

    if (self.sender.isMe) {
        return self.recipientResult;
    }

    return FTBMatchResultUnknown;
}

@end
