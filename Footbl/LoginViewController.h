//
//  LoginViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/7/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TemplateViewController.h"

@interface LoginViewController : TemplateViewController <UITextFieldDelegate>

@property (copy, nonatomic) void (^completionBlock)();
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UITextField *emailTextField;
@property (strong, nonatomic) UIImageView *emailIconImageView;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UIImageView *passwordIconImageView;
@property (strong, nonatomic) UILabel *informationLabel;

@end
