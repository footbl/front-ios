//
//  EditProfileViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/26/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateViewController.h"

@interface EditProfileViewController : TemplateViewController <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) UITextField *nameTextField;
@property (strong, nonatomic) UITextView *aboutMeTextView;
@property (strong, nonatomic) UITextView *placeholderTextView;

@end
