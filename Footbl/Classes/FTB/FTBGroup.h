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

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, strong) FTBUser *owner;
@property (nonatomic, copy) NSURL *pictureURL;
@property (nonatomic, assign, getter=isFeatured) BOOL featured;
@property (nonatomic, copy) NSArray *invites;
@property (nonatomic, copy) NSArray *members;

@property (nonatomic, assign, getter=isFreeToEdit) BOOL freeToEdit;
@property (nonatomic, assign) BOOL isNew;

- (BOOL)isWorld;
- (BOOL)isFriends;
- (BOOL)isDefault;
- (NSString *)sharingText;
- (void)saveStatusInLocalDatabase;

@end
