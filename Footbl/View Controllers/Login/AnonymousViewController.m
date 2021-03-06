//
//  AnonymousViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/26/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <SPHipster/SPHipster.h>

#import "AnonymousViewController.h"
#import "FacebookHelper.h"
#import "FootblNavigationController.h"
#import "FTBClient.h"
#import "ImportImageHelper.h"
#import "LoadingHelper.h"
#import "LoginViewController.h"
#import "SignupViewController.h"
#import "UIView+Frame.h"

@interface AnonymousViewController ()

@end

#pragma mark AnonymousViewController

@implementation AnonymousViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (IBAction)facebookAction:(id)sender {
    [FacebookHelper performAuthenticatedAction:^(NSError *error) {
        if (error) {
            SPLogError(@"Facebook error %@, %@", error, [error userInfo]);
            [[LoadingHelper sharedInstance] hideHud];
            [[ErrorHandler sharedInstance] displayError:error];
        } else {
            self.view.userInteractionEnabled = NO;
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=id,username,name,email,picture" parameters:nil];
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, NSDictionary *result, NSError *error) {
                if (result) {
                    [[FTBClient client] usersWithEmails:@[result[@"email"]] facebookIds:@[result[@"id"]] usernames:nil names:nil page:0 success:^(NSArray<FTBUser *> *users) {
                        if (users.count > 0) {
                            [[FTBClient client] loginWithEmail:result[@"email"] password:result[@"id"] success:^(FTBUser *user) {
                                self.view.userInteractionEnabled = YES;
                                [self dismissViewControllerAnimated:YES completion:nil];
                            } failure:^(NSError *error) {
                                [[ErrorHandler sharedInstance] displayError:error];
                            }];
                        } else {
                            SignupViewController *signupViewController = [[SignupViewController alloc] init];
                            signupViewController.email = result[@"email"];
                            signupViewController.name = result[@"name"];
                            signupViewController.password = result[@"id"];
                            signupViewController.passwordConfirmation = result[@"id"];
                            if (![result[@"picture"][@"data"][@"is_silhouette"] boolValue]) {
                                [[ImportImageHelper sharedInstance] importImageFromFacebookWithCompletionBlock:^(UIImage *image, NSError *error) {
                                    if (image) {
                                        signupViewController.profileImage = image;
                                    }
                                }];
                            }
                            signupViewController.completionBlock = ^{
                                [self dismissViewControllerAnimated:YES completion:nil];
                            };

                            FootblNavigationController *navigationViewController = [[FootblNavigationController alloc] initWithRootViewController:signupViewController];
                            [self presentViewController:navigationViewController animated:YES completion:nil];
                            self.view.userInteractionEnabled = YES;
                        }
                    } failure:^(NSError *error) {
                        [[ErrorHandler sharedInstance] displayError:error];
                    }];
                } else {
                    [[LoadingHelper sharedInstance] hideHud];
                    self.view.userInteractionEnabled = YES;
                }
            }];
        }
    }];
}

- (IBAction)loginAction:(UIButton *)sender {
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    loginViewController.completionBlock = ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    FootblNavigationController *navigationViewController = [[FootblNavigationController alloc] initWithRootViewController:loginViewController];
    [self presentViewController:navigationViewController animated:YES completion:nil];
}

- (IBAction)signupAction:(UIButton *)sender {
    SignupViewController *signupViewController = [[SignupViewController alloc] init];
    signupViewController.completionBlock = ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    FootblNavigationController *navigationViewController = [[FootblNavigationController alloc] initWithRootViewController:signupViewController];
    [self presentViewController:navigationViewController animated:YES completion:nil];
}

#pragma mark - Delegates & Data sources

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor ftb_viewMatchBackgroundColor];
    
    UIColor *textColor = [UIColor ftb_greenGrassColor];
    UIColor *highlightedColor = [UIColor colorWithRed:0.04 green:0.35 blue:0.16 alpha:1];
    
    UIView * (^generateView)(CGRect frame) = ^(CGRect frame) {
        frame.origin.x -= 1;
        frame.size.width += 2;
        UIView *view = [[UIView alloc] initWithFrame:frame];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.borderColor = [UIColor colorWithRed:227/255.f green:232/255.f blue:228/255.f alpha:1.00].CGColor;
        view.layer.borderWidth = 0.5;
        [self.view addSubview:view];
        return view;
    };
    
    NSString *text = NSLocalizedString(@"Anonymous user message", @"");
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, CGRectGetWidth(self.view.bounds) - 60, 234)];
    textLabel.numberOfLines = 0;
    [self.view addSubview:textLabel];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *headerAttributes = @{NSParagraphStyleAttributeName : paragraphStyle,
                                       NSFontAttributeName : [UIFont fontWithName:kFontNameLight size:21],
                                       NSForegroundColorAttributeName : [UIColor colorWithRed:122/255.f green:135/255.f blue:126/255.f alpha:1.00]};
    NSDictionary *bodyAttributes = @{NSParagraphStyleAttributeName : paragraphStyle,
                                     NSFontAttributeName : [UIFont fontWithName:kFontNameMedium size:18],
                                     NSForegroundColorAttributeName : [UIColor colorWithRed:122/255.f green:135/255.f blue:126/255.f alpha:1.00],
                                     NSKernAttributeName : @(-0.36)};
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    if ([text rangeOfString:@"\n"].location != NSNotFound) {
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[text componentsSeparatedByString:@"\n"].firstObject attributes:headerAttributes]];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[text componentsSeparatedByString:@"\n"].lastObject attributes:bodyAttributes]];
    } else {
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:text attributes:bodyAttributes]];
    }
    textLabel.attributedText = attributedString;
    
    CGRect facebookFrame = CGRectMake(0, 234, CGRectGetWidth(self.view.bounds), 52);
    generateView(facebookFrame);
    UIButton *facebookButton = [[UIButton alloc] initWithFrame:facebookFrame];
    [facebookButton setImage:[[UIImage imageNamed:@"login_with_facebook"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    facebookButton.titleLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:18];
    facebookButton.imageEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 30);
    facebookButton.titleEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
    facebookButton.imageView.tintColor = textColor;
    [facebookButton setTitle:NSLocalizedString(@"Log in with Facebook", @"") forState:UIControlStateNormal];
    [facebookButton setTitleColor:textColor forState:UIControlStateNormal];
    [facebookButton setTitleColor:highlightedColor forState:UIControlStateHighlighted];
    [facebookButton addTarget:self action:@selector(facebookAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:facebookButton];
    
    CGRect signupFrame = CGRectMake(0, CGRectGetMaxY(facebookButton.frame) + 10, CGRectGetWidth(self.view.bounds), 52);
    generateView(signupFrame);
    UIButton *signupButton = [[UIButton alloc] initWithFrame:signupFrame];
    [signupButton setTitle:NSLocalizedString(@"Create my account", @"") forState:UIControlStateNormal];
    [signupButton setTitleColor:textColor forState:UIControlStateNormal];
    [signupButton setTitleColor:highlightedColor forState:UIControlStateHighlighted];
    signupButton.titleLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:18];
    [signupButton addTarget:self action:@selector(signupAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signupButton];
}

@end
