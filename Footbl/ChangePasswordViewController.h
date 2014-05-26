//
//  ChangePasswordViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/26/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "SignupViewController.h"

@interface ChangePasswordViewController : TemplateViewController

@property (copy, nonatomic) void (^completionBlock)();
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UILabel *informationLabel;
@property (strong, nonatomic) UILabel *hintLabel;
@property (copy, nonatomic) NSString *oldPassword;
@property (copy, nonatomic) NSString *password;

@end
