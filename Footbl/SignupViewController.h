//
//  SignupViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/8/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TemplateViewController.h"

@interface SignupViewController : TemplateViewController <UITextFieldDelegate>

@property (copy, nonatomic) void (^completionBlock)();
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UILabel *informationLabel;
@property (strong, nonatomic) UILabel *hintLabel;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *passwordConfirmation;
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *fbToken;
@property (strong, nonatomic) UIImage *profileImage;

@end
