//
//  FTBGroup.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBModel.h"

@class FTBUser;

@interface FTBGroup : FTBModel

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *code;
@property (nonatomic, strong, readonly) FTBUser *owner;
@property (nonatomic, copy, readonly) NSURL *pictureURL;
@property (nonatomic, assign, readonly, getter=isFeatured) BOOL featured;
@property (nonatomic, copy, readonly) NSArray *invites;
@property (nonatomic, copy, readonly) NSArray *members;

@end
