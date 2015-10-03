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

@property (nonatomic, copy) NSString *facebookId;
@property (nonatomic, strong) FTBUser *creditedUser;
@property (nonatomic, strong) FTBUser *chargedUser;
@property (nonatomic, copy) NSNumber *value;
@property (nonatomic, assign) BOOL payed;

@end
