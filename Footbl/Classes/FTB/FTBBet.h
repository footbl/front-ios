//
//  FTBBet.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBModel.h"
#import "FTBConstants.h"

@class FTBUser;
@class FTBMatch;

@interface FTBBet : FTBModel

@property (nonatomic, strong, readonly) FTBUser *user;
@property (nonatomic, strong, readonly) FTBMatch *match;
@property (nonatomic, assign, readonly) NSNumber *bid;
@property (nonatomic, assign, readonly) FTBMatchResult result;

- (NSString *)valueString;
- (NSNumber *)toReturn;
- (NSString *)toReturnString;
- (NSNumber *)reward;
- (NSString *)rewardString;

@end
