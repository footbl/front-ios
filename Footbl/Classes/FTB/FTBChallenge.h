//
//  FTBChallenge.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBMatch.h"
#import "FTBModel.h"

@class FTBUser;

@interface FTBChallenge : FTBModel

@property (nonatomic, strong) FTBUser *challengerUser;
@property (nonatomic, strong) FTBUser *challengedUser;
@property (nonatomic, assign) FTBMatchResult challengerResult;
@property (nonatomic, assign) FTBMatchResult challengedResult;
@property (nonatomic, strong) FTBMatch *match;
@property (nonatomic, copy) NSNumber *bid;
@property (nonatomic, assign, getter=isAccepted) BOOL accepted;
@property (nonatomic, assign, getter=isWaiting) BOOL waiting;

@property (nonatomic, strong, readonly) FTBUser *me;
@property (nonatomic, strong, readonly) FTBUser *oponent;
@property (nonatomic, assign) FTBMatchResult myResult;
@property (nonatomic, assign) FTBMatchResult oponentResult;

- (NSString *)valueString;
- (NSNumber *)toReturn;
- (NSString *)toReturnString;

@end
