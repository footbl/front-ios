//
//  FTBMessage.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBModel.h"

@class FTBUser;

@interface FTBMessage : FTBModel

@property (nonatomic, strong) FTBUser *user;
@property (nonatomic, strong) FTBModel *room;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSArray<FTBUser *> *seenBy;

@property (nonatomic, assign) BOOL deliveryFailedValue;

@end
