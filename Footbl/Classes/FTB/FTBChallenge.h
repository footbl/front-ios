//
//  FTBChallenge.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBMatch.h"
#import "FTBModel.h"

typedef NS_ENUM(NSUInteger, FTBChallengeStatus) {
    FTBChallengeStatusWaiting,
    FTBChallengeStatusAccepted,
    FTBChallengeStatusRejected
};

@class FTBUser;

@interface FTBChallenge : FTBModel

@property (nonatomic, strong) FTBUser *sender;
@property (nonatomic, strong) FTBUser *recipient;
@property (nonatomic, assign) FTBMatchResult senderResult;
@property (nonatomic, assign) FTBMatchResult recipientResult;
@property (nonatomic, strong) FTBMatch *match;
@property (nonatomic, copy) NSNumber *bid;
@property (nonatomic, assign) FTBChallengeStatus status;

@property (nonatomic, strong, readonly) FTBUser *me;
@property (nonatomic, strong, readonly) FTBUser *oponent;
@property (nonatomic, assign) FTBMatchResult myResult;
@property (nonatomic, assign) FTBMatchResult oponentResult;

- (NSString *)valueString;
- (NSNumber *)toReturn;
- (NSString *)toReturnString;
- (NSNumber *)reward;
- (NSString *)rewardString;

@end
