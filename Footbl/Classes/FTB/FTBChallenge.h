//
//  FTBChallenge.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBModel.h"
#import "FTBMatch.h"

@class FTBUser;

@interface FTBChallenge : FTBModel

@property (nonatomic, strong, readonly) FTBUser *challengerUser;
@property (nonatomic, strong, readonly) FTBUser *challengedUser;
@property (nonatomic, assign, readonly) FTBMatchResult challengerResult;
@property (nonatomic, assign, readonly) FTBMatchResult challengedResult;
@property (nonatomic, strong, readonly) FTBMatch *match;
@property (nonatomic, assign, readonly) NSUInteger bid;
@property (nonatomic, assign, readonly, getter=isAccepted) BOOL accepted;

@end
