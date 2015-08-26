//
//  FTBPrize.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBModel.h"
#import "FTBConstants.h"

@class FTBUser;

@interface FTBPrize : FTBModel

@property (nonatomic, strong, readonly) FTBUser *user;
@property (nonatomic, assign, readonly) NSNumber *value;
@property (nonatomic, assign, readonly) FTBPrizeType type;
@property (nonatomic, copy, readonly) NSArray *seenBy;

@end
