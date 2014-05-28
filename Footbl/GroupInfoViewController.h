//
//  GroupInfoViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/2/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "GroupInfoBaseViewController.h"

@class Group;

@interface GroupInfoViewController : GroupInfoBaseViewController <UITextFieldDelegate>

@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) UILabel *championshipLabel;
@property (strong, nonatomic) UIButton *leaveGroupButton;
@property (strong, nonatomic) UIButton *addNewMembersGroupButton;
@property (strong, nonatomic) UISwitch *freeToEditSwich;

@end
