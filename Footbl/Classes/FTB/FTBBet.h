//
//  FTBBet.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBModel.h"
#import "FTBMatch.h"

@interface FTBBet : FTBModel

@property (nonatomic, strong, readonly) NSString *user;
@property (nonatomic, strong, readonly) NSString *match;
@property (nonatomic, assign, readonly) NSNumber *bid;
@property (nonatomic, assign, readonly) FTBMatchResult result;

@end
