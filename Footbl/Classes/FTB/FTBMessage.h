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

@property (nonatomic, strong, readonly) FTBUser *user;
@property (nonatomic, strong, readonly) FTBModel *room;
@property (nonatomic, copy, readonly) NSString *message;
@property (nonatomic, copy, readonly) NSString *type;
@property (nonatomic, copy, readonly) NSArray<FTBUser *> *seenBy;

@property (nonatomic, assign) BOOL deliveryFailedValue;

@end
