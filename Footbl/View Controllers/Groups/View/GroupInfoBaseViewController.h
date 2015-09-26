//
//  GroupInfoBaseViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/3/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateViewController.h"

@interface GroupInfoBaseViewController : TemplateViewController <UITextFieldDelegate>

@property (strong, nonatomic) UITextField *nameTextField;
@property (strong, nonatomic) UILabel *nameSizeLimitLabel;
@property (strong, nonatomic) UIButton *groupImageButton;
@property (strong, nonatomic) UIView *groupImageButtonBorder;

- (void)shakeLimitLabel;
- (void)updateLimitTextForLength:(NSInteger)length;;
- (IBAction)selectImageAction:(id)sender;

@end