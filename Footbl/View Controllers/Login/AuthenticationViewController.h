//
//  AuthenticationViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/7/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TemplateViewController.h"

@interface AuthenticationViewController : TemplateViewController

@property (copy, nonatomic) void (^completionBlock)();
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

- (IBAction)loginAction:(UIButton *)sender;

@end
