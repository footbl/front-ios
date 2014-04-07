//
//  AuthenticationViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/7/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "AuthenticationViewController.h"
#import "FootblAPI.h"
#import "LoginViewController.h"

@interface AuthenticationViewController ()

@end

#pragma mark AuthenticationViewController

@implementation AuthenticationViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (IBAction)facebookAction:(id)sender {
    
}

- (IBAction)signupAction:(id)sender {
    LoginViewController *loginViewController = [LoginViewController new];
    [self.navigationController pushViewController:loginViewController animated:YES];
}

- (IBAction)skipLoginAction:(id)sender {
    [[FootblAPI sharedAPI] createAccountWithSuccess:^{
        if (self.completionBlock) self.completionBlock();
    } failure:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
        [alert show];
    }];
}

#pragma mark - Delegates & Data sources

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.navigationController.viewControllers = @[self];
    
    UIColor *lightGreen = [UIColor colorWithRed:0.46 green:0.95 blue:0.36 alpha:1];
    UIColor *darkGreen = [UIColor colorWithRed:0.42 green:0.84 blue:0.16 alpha:1];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    [gradientLayer setColors:@[(id)lightGreen.CGColor, (id)darkGreen.CGColor]];
    [gradientLayer setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 214)];
    [self.view.layer insertSublayer:gradientLayer atIndex:0];
    
    CGFloat buttonMargin = 60;
    
    UIButton *signupButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonMargin, CGRectGetHeight(self.view.bounds) - 184, CGRectGetWidth(self.view.bounds) - buttonMargin * 2, 52)];
    [signupButton setTitle:NSLocalizedString(@"Sign up", @"") forState:UIControlStateNormal];
    [signupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signupButton setBackgroundColor:darkGreen];
    signupButton.clipsToBounds = YES;
    signupButton.layer.cornerRadius = 5;
    signupButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [signupButton addTarget:self action:@selector(signupAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signupButton];
    
    UIButton *facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonMargin, CGRectGetHeight(self.view.bounds) - 117, CGRectGetWidth(self.view.bounds) - buttonMargin * 2, 52)];
    [facebookButton setTitle:NSLocalizedString(@"Log in with Facebook", @"") forState:UIControlStateNormal];
    [facebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [facebookButton setBackgroundColor:[UIColor colorWithRed:0.24 green:0.35 blue:0.59 alpha:1]];
    facebookButton.clipsToBounds = YES;
    facebookButton.layer.cornerRadius = 5;
    facebookButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [facebookButton addTarget:self action:@selector(facebookAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:facebookButton];
    
    UIButton *skipLoginButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonMargin, CGRectGetHeight(self.view.bounds) - 60, CGRectGetWidth(self.view.bounds) - buttonMargin * 2, 52)];
    [skipLoginButton setTitle:NSLocalizedString(@"Skip login", @"") forState:UIControlStateNormal];
    [skipLoginButton setTitleColor:[UIColor colorWithRed:0.48 green:0.48 blue:0.48 alpha:1] forState:UIControlStateNormal];
    skipLoginButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [skipLoginButton addTarget:self action:@selector(skipLoginAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipLoginButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
