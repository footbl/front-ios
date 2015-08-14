//
//  FTBBet.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBModel.h"
#import "FTBMatch.h"

@class FTBUser;

@interface FTBBet : FTBModel

@property (nonatomic, strong, readonly) FTBUser *user;
@property (nonatomic, strong, readonly) FTBMatch *match;
@property (nonatomic, assign, readonly) NSUInteger bid;
@property (nonatomic, assign, readonly) FTBMatchResult result;

@end
