//
//  FTBCreditRequest.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBModel.h"

@class FTBUser;

@interface FTBCreditRequest : FTBModel

@property (nonatomic, copy, readonly) NSString *facebookId;
@property (nonatomic, strong, readonly) FTBUser *creditedUser;
@property (nonatomic, strong, readonly) FTBUser *chargedUser;
@property (nonatomic, copy, readonly) NSNumber *value;
@property (nonatomic, assign, readonly) BOOL payed;

@end
