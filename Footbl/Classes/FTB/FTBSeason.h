//
//  FTBSeason.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBModel.h"

@interface FTBSeason : FTBModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *sponsor;
@property (nonatomic, copy) NSString *gift;
@property (nonatomic, copy) NSDate *finishAt;

@property (nonatomic, readonly) NSInteger daysToResetWallet;

@end
