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
#import "UIView+Frame.h"

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
    if ([[FootblAPI sharedAPI] isAuthenticated]) {
        if (self.completionBlock) self.completionBlock();
        return;
    }
    
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
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundImageView.image = [UIImage imageNamed:@"signup_bg"];
    backgroundImageView.contentMode = UIViewContentModeTop;
    [self.view addSubview:backgroundImageView];
    
    UIButton *signupButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 210, CGRectGetWidth(self.view.bounds), 52)];
    [signupButton setTitle:NSLocalizedString(@"Sign up", @"") forState:UIControlStateNormal];
    [signupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signupButton setTitleColor:[UIColor lightTextColor] forState:UIControlStateHighlighted];
    signupButton.titleLabel.font = [UIFont fontWithName:kFontNameSystemLight size:30];
    [signupButton addTarget:self action:@selector(signupAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signupButton];
    
    UILabel *orLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(signupButton.frame), 100, 20)];
    orLabel.text = NSLocalizedString(@"Or", @"").lowercaseString;
    orLabel.textColor = [UIColor colorWithWhite:1 alpha:0.6];
    orLabel.font = [UIFont fontWithName:kFontNameSystemLight size:12];
    orLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:orLabel];

    CGSize size = [orLabel sizeThatFits:CGSizeMake(INT_MAX, CGRectGetHeight(orLabel.frame))];
    CGRect frame = orLabel.frame;
    frame.size.width = roundf(size.width) + 30;
    CGPoint center = CGPointMake(CGRectGetMidX(self.view.bounds), orLabel.center.y);
    orLabel.frame = frame;
    orLabel.center = center;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(22, CGRectGetMidY(orLabel.frame) + 1, orLabel.frameX - 22, 0.5)];
    lineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    [self.view addSubview:lineView];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(orLabel.frame), CGRectGetMidY(orLabel.frame) + 1, self.view.frameWidth - (CGRectGetMaxX(orLabel.frame)) - 22, 0.5)];
    lineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    [self.view addSubview:lineView];

    UIButton *facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(signupButton.frame) + 15, CGRectGetWidth(self.view.bounds), 52)];
    [facebookButton setImage:[UIImage imageNamed:@"login_with_facebook"] forState:UIControlStateNormal];
    facebookButton.adjustsImageWhenHighlighted = NO;
    [facebookButton setTitle:NSLocalizedString(@"Log in with Facebook", @"") forState:UIControlStateNormal];
    [facebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [facebookButton setTitleColor:[UIColor lightTextColor] forState:UIControlStateHighlighted];
    facebookButton.titleLabel.font = [UIFont fontWithName:kFontNameSystemLight size:21];
    facebookButton.imageEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 30);
    facebookButton.titleEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
    [facebookButton addTarget:self action:@selector(facebookAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:facebookButton];
    
    UIButton *skipLoginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 62, CGRectGetWidth(self.view.bounds), 52)];
    [skipLoginButton setTitle:NSLocalizedString(@"Skip for now", @"") forState:UIControlStateNormal];
    [skipLoginButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateNormal];
    [skipLoginButton setTitleColor:[UIColor lightTextColor] forState:UIControlStateHighlighted];
    skipLoginButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [skipLoginButton addTarget:self action:@selector(skipLoginAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipLoginButton];
    
    for (UIView *view in self.view.subviews) {
        if (view != backgroundImageView) {
            view.alpha = 0;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] delay:[FootblAppearance speedForAnimation:FootblAnimationDefault] options:UIViewAnimationOptionAllowUserInteraction animations:^{
        for (UIView *view in self.view.subviews) {
            view.alpha = 1;
        }
    } completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
