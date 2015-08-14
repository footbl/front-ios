//
//  FTBSeason.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBModel.h"

@interface FTBSeason : FTBModel

@property (nonatomic, copy, readonly) NSString *sponsor;
@property (nonatomic, copy, readonly) NSString *gift;
@property (nonatomic, copy, readonly) NSDate *finishAt;

@end
