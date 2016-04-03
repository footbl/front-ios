//
//  FTBPrize.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBConstants.h"
#import "FTBModel.h"

@class FTBUser;

@interface FTBPrize : FTBModel

@property (nonatomic, strong) FTBUser *user;
@property (nonatomic, copy) NSNumber *value;
@property (nonatomic, assign) FTBPrizeType type;
@property (nonatomic, copy) NSArray<FTBUser *> *seenBy;

@end
