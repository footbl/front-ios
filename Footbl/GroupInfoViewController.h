//
//  GroupInfoViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/2/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TemplateViewController.h"

@class Group;

@interface GroupInfoViewController : TemplateViewController <UITextFieldDelegate>

@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) UITextField *nameTextField;
@property (strong, nonatomic) UIImageView *groupImageView;
@property (strong, nonatomic) UILabel *championshipLabel;
@property (strong, nonatomic) UIButton *leaveGroupButton;

@end
