//
//  AuthenticationViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/7/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <SPHipster/SPHipster.h>
#import "AuthenticationViewController.h"
#import "FTAuthenticationManager.h"
#import "ImportImageHelper.h"
#import "LoginViewController.h"
#import "SignupViewController.h"
#import "UIView+Frame.h"

@interface AuthenticationViewController ()

@end

#pragma mark AuthenticationViewController

@implementation AuthenticationViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (IBAction)facebookAction:(id)sender {
    [[FTAuthenticationManager sharedManager] authenticateFacebookWithCompletion:^(FBSession *session, FBSessionState status, NSError *error) {
        if (error) {
            SPLogError(@"Facebook error %@, %@", error, [error userInfo]);
            [[ErrorHandler sharedInstance] displayError:error];
        } else {
            self.view.userInteractionEnabled = NO;
            [self setSubviewsHidden:YES animated:YES];
            [UIView animateWithDuration:FTBAnimationDuration animations:^{
                self.activityIndicatorView.alpha = 1;
                [self.activityIndicatorView startAnimating];
            }];
            
            [[FBRequest requestForGraphPath:@"me?fields=id,name,email,picture"] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (result) {
                    [[FTAuthenticationManager sharedManager] loginWithFacebookToken:[FBSession activeSession].accessTokenData.accessToken success:^(id response) {
                        self.view.userInteractionEnabled = YES;
                        if (self.completionBlock) self.completionBlock();
                    } failure:^(NSError *error) {
                        SignupViewController *signupViewController = [SignupViewController new];
                        signupViewController.email = result[@"email"];
                        signupViewController.name = result[@"name"];
                        signupViewController.password = FBAuthenticationManagerGeneratePasswordWithId(result[@"id"]);
                        signupViewController.passwordConfirmation = signupViewController.password;
                        signupViewController.completionBlock = self.completionBlock;
                        if (![result[@"picture"][@"data"][@"is_silhouette"] boolValue]) {
                            [[ImportImageHelper sharedInstance] importImageFromFacebookWithCompletionBlock:^(UIImage *image, NSError *error) {
                                if (image) {
                                    signupViewController.profileImage = image;
                                }
                            }];
                        }
                        signupViewController.fbToken = [FBSession activeSession].accessTokenData.accessToken;
                        [self.navigationController pushViewController:signupViewController animated:NO];
                        self.view.userInteractionEnabled = YES;
                    }];
                } else {
                    self.view.userInteractionEnabled = YES;
                    [self setSubviewsHidden:NO animated:YES];
                    [UIView animateWithDuration:FTBAnimationDuration animations:^{
                        self.activityIndicatorView.alpha = 0;
                    } completion:^(BOOL finished) {
                        [self.activityIndicatorView stopAnimating];
                    }];
                }
            }];
        }
    }];
}

- (IBAction)loginAction:(UIButton *)sender {
    UIColor *normalColor = [sender titleColorForState:UIControlStateNormal];
    [sender setTitleColor:[sender titleColorForState:UIControlStateHighlighted] forState:UIControlStateNormal];
    
    [self setSubviewsHidden:YES animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(FTBAnimationDuration * 1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        LoginViewController *loginViewController = [LoginViewController new];
        loginViewController.completionBlock = self.completionBlock;
        [self.navigationController pushViewController:loginViewController animated:NO];
        [sender setTitleColor:normalColor forState:UIControlStateNormal];
    });
}

- (IBAction)signupAction:(UIButton *)sender {
    UIColor *normalColor = [sender titleColorForState:UIControlStateNormal];
    [sender setTitleColor:[sender titleColorForState:UIControlStateHighlighted] forState:UIControlStateNormal];
    
    [self setSubviewsHidden:YES animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(FTBAnimationDuration * 1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SignupViewController *signupViewController = [SignupViewController new];
        signupViewController.completionBlock = self.completionBlock;
        [self.navigationController pushViewController:signupViewController animated:NO];
        [sender setTitleColor:normalColor forState:UIControlStateNormal];
    });
}

- (IBAction)skipLoginAction:(id)sender {
    if ([FTAuthenticationManager sharedManager].isAuthenticated) {
        if (self.completionBlock) self.completionBlock();
        return;
    }
    
    [[FTAuthenticationManager sharedManager] createUserWithSuccess:^(id response) {
        if (self.completionBlock) self.completionBlock();
    } failure:^(NSError *error) {
        [[ErrorHandler sharedInstance] displayError:error];
    }];
}

- (void)setSubviewsHidden:(BOOL)hidden animated:(BOOL)animated {
    [UIView animateWithDuration:animated ? FTBAnimationDuration : 0 animations:^{
        for (UIView *view in self.view.subviews) {
            if (view != self.backgroundImageView && view != self.activityIndicatorView) {
                view.alpha = !hidden;
            }
        }
    }];
}

#pragma mark - Delegates & Data sources

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.navigationController.viewControllers = @[self];
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.backgroundImageView.image = [UIImage imageNamed:@"signup_bg"];
    if (self.backgroundImageView.image.size.height < CGRectGetHeight(self.view.frame)) {
        self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    } else {
        self.backgroundImageView.contentMode = UIViewContentModeTop;
    }
    [self.view addSubview:self.backgroundImageView];
    
    BOOL tallView = self.view.height > 500;
    
    UIButton *signupButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - (tallView ? 210 : 180), CGRectGetWidth(self.view.bounds), 52)];
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
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(22, CGRectGetMidY(orLabel.frame) + 1, orLabel.x - 22, 0.5)];
    lineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    [self.view addSubview:lineView];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(orLabel.frame), CGRectGetMidY(orLabel.frame) + 1, self.view.width - (CGRectGetMaxX(orLabel.frame)) - 22, 0.5)];
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
    
    UIButton *skipLoginButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds) / 2, CGRectGetHeight(self.view.bounds) - 62, CGRectGetWidth(self.view.bounds) / 2, 52)];
    [skipLoginButton setTitle:NSLocalizedString(@"Skip for now", @"") forState:UIControlStateNormal];
    [skipLoginButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateNormal];
    [skipLoginButton setTitleColor:[UIColor lightTextColor] forState:UIControlStateHighlighted];
    skipLoginButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [skipLoginButton addTarget:self action:@selector(skipLoginAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipLoginButton];
    
    UIButton *signinButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 62, CGRectGetWidth(self.view.bounds) / 2, 52)];
    [signinButton setTitle:NSLocalizedString(@"Sign in", @"") forState:UIControlStateNormal];
    [signinButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateNormal];
    [signinButton setTitleColor:[UIColor lightTextColor] forState:UIControlStateHighlighted];
    signinButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [signinButton addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signinButton];
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicatorView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(orLabel.frame));
    self.activityIndicatorView.hidesWhenStopped = YES;
    self.activityIndicatorView.alpha = 0;
    [self.view addSubview:self.activityIndicatorView];
    
    [self setSubviewsHidden:YES animated:NO];
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
    
    [self setSubviewsHidden:NO animated:YES];
    self.activityIndicatorView.alpha = 0;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.activityIndicatorView stopAnimating];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
