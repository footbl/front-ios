//
//  GroupInfoViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/2/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "GroupInfoBaseViewController.h"

@class FTBGroup;

@interface GroupInfoViewController : GroupInfoBaseViewController <UITextFieldDelegate>

@property (strong, nonatomic) FTBGroup *group;
@property (strong, nonatomic) UILabel *championshipLabel;
@property (strong, nonatomic) UIButton *leaveGroupButton;
@property (strong, nonatomic) UIButton *addNewMembersGroupButton;
@property (strong, nonatomic) UISwitch *freeToEditSwich;
@property (strong, nonatomic) UISwitch *notificationsSwitch;

@end
