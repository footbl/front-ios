//
//  SignupViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/8/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "SignupViewController.h"
#import "AuthenticationViewController.h"
#import "FacebookHelper.h"
#import "FTBClient.h"
#import "FTBUser.h"
#import "ImportImageHelper.h"
#import "LoadingHelper.h"
#import "LoginViewController.h"
#import "NSString+Validations.h"
#import "UILabel+Shake.h"
#import "UIView+Frame.h"

@interface SignupViewController () <UIAlertViewDelegate>

@property (assign, nonatomic) BOOL statusBarVisible;
@property (assign, nonatomic, getter = isEmailConfirmed) BOOL emailConfirmed;
@property (strong, nonatomic) UIButton *profileImageButton;
@property (strong, nonatomic) UIView *textFieldBackground;
@property (strong, nonatomic) UIView *importProfileImageOptionsView;

@end

#pragma mark SignupViewController

@implementation SignupViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (IBAction)cancelAction:(id)sender {
    if (self.navigationController.viewControllers.firstObject == self) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.statusBarVisible = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self setSubviewsHidden:YES animated:YES];
    [self.textField resignFirstResponder];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(FTBAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:NO];
    });
}

- (IBAction)signupAction:(id)sender {
    FTBBlockError failureBlock = ^(NSError *error) {
        [[LoadingHelper sharedInstance] hideHud];
        if (error) {
            self.view.userInteractionEnabled = YES;
            [[ErrorHandler sharedInstance] displayError:error];
            
            self.email = nil;
            self.username = nil;
            self.textField.text = @"";
            self.importProfileImageOptionsView.hidden = YES;
            self.informationLabel.y = 93;

            self.informationLabel.alpha = 1;
            self.textField.alpha = 1;
            self.textFieldBackground.alpha = 1;
            self.profileImageButton.alpha = 0;
            [self reloadTextField];
            [self.textField becomeFirstResponder];
        }
    };
    
    self.view.userInteractionEnabled = NO;
    [self.textField resignFirstResponder];
    
    [[LoadingHelper sharedInstance] showHud];
	
	[[FTBClient client] createUserWithPassword:self.password success:^(id object) {
		NSString *username = [self.username stringByReplacingOccurrencesOfString:@"@" withString:@"" options:kNilOptions range:NSMakeRange(0, 1)];
		[[FTBClient client] updateUsername:username name:self.name email:self.email password:self.password fbToken:self.fbToken apnsToken:nil image:self.profileImage about:self.aboutMe success:^(id response) {
			[[LoadingHelper sharedInstance] hideHud];
			if (self.completionBlock) self.completionBlock();
		} failure:^(NSError *error) {
			[[FTBClient client] logout];
			failureBlock(error);
		}];
	} failure:failureBlock];
}

- (IBAction)continueAction:(id)sender {
    void(^switchInputBlock)(BOOL shouldShowKeyboard) = ^(BOOL shouldShowKeyboard) {
        self.hintLabel.text = @"";
        [UIView animateWithDuration:FTBAnimationDuration animations:^{
            self.informationLabel.alpha = 0;
            self.textField.alpha = 0;
            self.hintLabel.alpha = 0;
            if (shouldShowKeyboard) {
                self.profileImageButton.alpha = 0;
            } else {
                self.textFieldBackground.alpha = 0;
            }
        } completion:^(BOOL finished) {
            self.textField.text = @"";
            [self reloadTextField];
            [self.textField resignFirstResponder];
            if (shouldShowKeyboard) {
                [self.textField becomeFirstResponder];
            }
            [UIView animateWithDuration:FTBAnimationDuration animations:^{
                self.informationLabel.alpha = 1;
                self.textField.alpha = 1;
                self.hintLabel.alpha = 1;
                if (shouldShowKeyboard) {
                    self.textFieldBackground.alpha = 1;
                } else {
                    self.profileImageButton.alpha = 1;
                }
            }];
        }];
    };
    
    void(^invalidInputBlock)() = ^() {
        [self showHint];
        [self.textField shakeAndChangeColor];
    };
    
    if (!self.email) {
        if (self.textField.text.isEmail) {
            NSString *email = [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            if (self.isEmailConfirmed) {
                self.email = [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
                switchInputBlock(YES);
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Is this correct?", @"") message:[NSString stringWithFormat:NSLocalizedString(@"You entered your email as %@", @""), email] delegate:self cancelButtonTitle:NSLocalizedString(@"No", @"") otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
                [alert show];
                return;
            }
        } else {
            invalidInputBlock();
        }
    } else if (!self.name) {
        if (self.textField.text.isValidName) {
            self.name = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            switchInputBlock(YES);
        } else {
            invalidInputBlock();
        }
    } else if (!self.password) {
        if (self.textField.text.isValidPassword) {
            self.password = self.textField.text;
            switchInputBlock(YES);
        } else {
            invalidInputBlock();
        }
    } else if (!self.username) {
        if (self.textField.text.isValidUsername) {
            self.view.userInteractionEnabled = NO;
            [self.activityIndicatorView startAnimating];
			
			NSString *text = [self.textField.text stringByReplacingOccurrencesOfString:@"@" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 1)];
			[[FTBClient client] usersWithEmails:nil facebookIds:nil usernames:@[text] names:nil page:0 success:^(NSArray *response) {
                self.view.userInteractionEnabled = YES;
                [self.activityIndicatorView stopAnimating];
                if (response.count > 0) {
                    invalidInputBlock();
                    self.hintLabel.text = NSLocalizedString(@"Username already taken, please choose another", @"");
                    [self.textField becomeFirstResponder];
                } else {
                    self.username = self.textField.text;
                    if (!self.aboutMe) {
                        switchInputBlock(YES);
                    } else if (!self.profileImage) {
                        switchInputBlock(NO);
                    } else {
                        [self signupAction:sender];
                    }
                }
            } failure:^(NSError *error) {
                self.view.userInteractionEnabled = YES;
                [self.activityIndicatorView stopAnimating];
            }];
        } else {
            invalidInputBlock();
        }
    } else if (!self.aboutMe) {
        if (self.textField.text.isValidAboutMe) {
            self.aboutMe = self.textField.text;
            if (self.profileImage) {
                [self signupAction:sender];
            } else {
                switchInputBlock(NO);
            }
        } else {
            invalidInputBlock();
        }
    } else {
        [self signupAction:sender];
    }
}

- (IBAction)importFromFacebookAction:(id)sender {
    [FacebookHelper performAuthenticatedAction:^(NSError *error) {
        [[ImportImageHelper sharedInstance] importImageFromFacebookWithCompletionBlock:^(UIImage *image, NSError *error) {
            if (image) {
                [self.profileImageButton setImage:image forState:UIControlStateNormal];
                self.profileImage = image;
            }
        }];
    }];
}

- (IBAction)importFromPhotoLibraryAction:(id)sender {
    [[ImportImageHelper sharedInstance] importFromGalleryWithCompletionBlock:^(UIImage *image, NSError *error) {
        if (image) {
            [self.profileImageButton setImage:image forState:UIControlStateNormal];
            self.profileImage = image;
        }
    }];
}

- (IBAction)importFromCameraAction:(id)sender {
    [[ImportImageHelper sharedInstance] importFromCameraWithCompletionBlock:^(UIImage *image, NSError *error) {
        if (image) {
            [self.profileImageButton setImage:image forState:UIControlStateNormal];
            self.profileImage = image;
        }
    }];
}

- (void)setSubviewsHidden:(BOOL)hidden animated:(BOOL)animated {
    [UIView animateWithDuration:animated ? FTBAnimationDuration : 0 animations:^{
        for (UIView *view in self.view.subviews) {
            if (view != self.backgroundImageView) {
                view.alpha = !hidden;
            }
        }
    }];
}

- (BOOL)prefersStatusBarHidden {
    return !self.statusBarVisible && self.navigationController.viewControllers.firstObject != self;
}

- (void)showHint {
    if (!self.email) {
        self.hintLabel.text = NSLocalizedString(@"Sign up text: email hint", @"");
    } else if (!self.name) {
        self.hintLabel.text = NSLocalizedString(@"Sign up text: name hint", @"");
    } else if (!self.password) {
        self.hintLabel.text = NSLocalizedString(@"Sign up text: password hint", @"");
    } else if (!self.username) {
        self.hintLabel.text = NSLocalizedString(@"Sign up text: username hint", @"");
    } else if (!self.aboutMe) {
        self.hintLabel.text = NSLocalizedString(@"Sign up text: about hint", @"");
    } else if (!self.profileImage) {
        self.hintLabel.text = @"";
    }
    
    CGRect frame = self.hintLabel.frame;
    frame.size.height = [self.hintLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.hintLabel.frame), INT_MAX)].height + 20;
    self.hintLabel.frame = frame;
    if (self.hintLabel.text.length == 0) {
        self.hintLabel.alpha = 0;
    }
    [UIView animateWithDuration:FTBAnimationDuration animations:^{
        self.hintLabel.alpha = 1;
    }];
}

- (void)reloadTextField {
    NSString *text;
    
    self.importProfileImageOptionsView.hidden = YES;
    
    if (!self.email) {
        text = NSLocalizedString(@"Sign up text: email", @"");
        
        self.textField.secureTextEntry = NO;
        self.textField.keyboardType = UIKeyboardTypeEmailAddress;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.returnKeyType = UIReturnKeyNext;
        self.textField.enablesReturnKeyAutomatically = YES;
    } else if (!self.name) {
        text = NSLocalizedString(@"Sign up text: name", @"");
        
        self.textField.secureTextEntry = NO;
        self.textField.keyboardType = UIKeyboardTypeAlphabet;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        self.textField.autocorrectionType = UITextAutocorrectionTypeYes;
        self.textField.returnKeyType = UIReturnKeyNext;
        self.textField.enablesReturnKeyAutomatically = YES;
    } else if (!self.password) {
        text = NSLocalizedString(@"Sign up text: password", @"");
        
        self.textField.secureTextEntry = NO;
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.returnKeyType = UIReturnKeyNext;
        self.textField.enablesReturnKeyAutomatically = YES;
    } else if (!self.username) {
        text = NSLocalizedString(@"Sign up text: username", @"");
        
        self.textField.secureTextEntry = NO;
        self.textField.keyboardType = UIKeyboardTypeAlphabet;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.returnKeyType = UIReturnKeyNext;
        self.textField.enablesReturnKeyAutomatically = YES;
        self.textField.text = @"@";
    } else if (!self.aboutMe) {
        text = NSLocalizedString(@"Sign up text: about", @"");
        
        self.textField.secureTextEntry = NO;
        self.textField.keyboardType = UIKeyboardTypeAlphabet;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        self.textField.autocorrectionType = UITextAutocorrectionTypeDefault;
        self.textField.returnKeyType = UIReturnKeyDone;
        self.textField.enablesReturnKeyAutomatically = NO;
    } else if (!self.profileImage) {
        text = NSLocalizedString(@"Sign up text: profile", @"");
        
        self.importProfileImageOptionsView.hidden = NO;
        self.importProfileImageOptionsView.y = self.view.height - self.importProfileImageOptionsView.height;
        self.informationLabel.y = CGRectGetMaxY(self.profileImageButton.frame) - 5;
        [self.textField resignFirstResponder];
    }
    
    if (text && [text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
        if ([text rangeOfString:@"\n"].location != NSNotFound) {
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[text componentsSeparatedByString:@"\n"].firstObject attributes:[self informationTitleTextAttributes]]];
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[text componentsSeparatedByString:@"\n"].lastObject attributes:[self informationBodyTextAttributes]]];
        } else {
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:text attributes:[self informationBodyTextAttributes]]];
        }
        
        self.informationLabel.attributedText = attributedString;
    } else {
        self.informationLabel.attributedText = nil;
        self.informationLabel.text = @"";
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (NSDictionary *)informationTitleTextAttributes {
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    return @{NSParagraphStyleAttributeName : paragraphStyle,
             NSFontAttributeName : [UIFont fontWithName:kFontNameSystemLight size:24],
             NSForegroundColorAttributeName : [UIColor whiteColor]};
}

- (NSDictionary *)informationBodyTextAttributes {
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    return @{NSParagraphStyleAttributeName : paragraphStyle,
             NSFontAttributeName : [UIFont fontWithName:kFontNameSystemLight size:18],
             NSForegroundColorAttributeName : [UIColor whiteColor]};
}

#pragma mark - Delegates & Data sources

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.isEmailConfirmed) {
        if (buttonIndex == 1) {
            [LoginViewController setEmail:self.textField.text];
			UINavigationController *navigationController = self.navigationController;
			AuthenticationViewController *authenticationViewController = nil;
			if ([navigationController.viewControllers.firstObject isKindOfClass:[AuthenticationViewController class]]) {
				authenticationViewController = navigationController.viewControllers.firstObject;
				[navigationController popToRootViewControllerAnimated:YES];
			} else {
				
				authenticationViewController = [[AuthenticationViewController alloc] init];
				authenticationViewController.completionBlock = ^{
					[navigationController dismissViewControllerAnimated:YES completion:nil];
				};
				[navigationController setViewControllers:@[authenticationViewController] animated:YES];
			}
			
			if ([authenticationViewController respondsToSelector:@selector(loginAction:)]) {
				[authenticationViewController performSelector:@selector(loginAction:) withObject:nil afterDelay:1.2];
			}
        } else {
            self.emailConfirmed = NO;
            self.textField.text = @"";
            [self reloadTextField];
            [self.textField becomeFirstResponder];
        }
    } else {
        BOOL confirmed = (buttonIndex == 1);
        self.emailConfirmed = confirmed;
        
        if (confirmed) {
            self.view.userInteractionEnabled = NO;
            [self.textField resignFirstResponder];
            
            [self.activityIndicatorView startAnimating];
			
			[[FTBClient client] usersWithEmails:@[self.textField.text] facebookIds:nil usernames:nil names:nil page:0 success:^(NSArray *response) {
                self.view.userInteractionEnabled = YES;
                [self.activityIndicatorView stopAnimating];
                if (response.count > 0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Email already exists.\nDo you want to log in instead?", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"No", @"") otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
                    [alert show];
                } else {
                    [self continueAction:alertView];
                }
            } failure:^(NSError *error) {
                self.view.userInteractionEnabled = YES;
                [self.activityIndicatorView stopAnimating];
                [[ErrorHandler sharedInstance] displayError:error];
            }];
        }
    }
}

#pragma mark - UITextField delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [UIView animateWithDuration:FTBAnimationDuration animations:^{
        self.hintLabel.alpha = 0;
    }];
    
    if (self.password.length > 0 && self.username.length == 0) {
        if (range.location == 0) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self continueAction:textField];
    
    return YES;
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Continue", @"") style:UIBarButtonItemStylePlain target:self action:@selector(continueAction:)];
    
    self.title = NSLocalizedString(@"Sign up", @"");
    
    self.statusBarVisible = NO;
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.backgroundImageView.image = [UIImage imageNamed:@"signup_bg"];
    if (self.backgroundImageView.image.size.height < CGRectGetHeight(self.view.frame)) {
        self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    } else {
        self.backgroundImageView.contentMode = UIViewContentModeTop;
    }
    [self.view addSubview:self.backgroundImageView];
    
    UIImageView *signupImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    signupImageView.image = [UIImage imageNamed:@"signup_step2_bg"];
    if (signupImageView.image.size.height < CGRectGetHeight(self.view.frame)) {
        signupImageView.contentMode = UIViewContentModeScaleAspectFill;
    } else {
        signupImageView.contentMode = UIViewContentModeTop;
    }
    signupImageView.alpha = 0;
    [self.view addSubview:signupImageView];
    
    self.informationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 93, CGRectGetWidth(self.view.bounds), 112)];
    self.informationLabel.numberOfLines = 0;
    self.informationLabel.alpha = 0;
    [self.view addSubview:self.informationLabel];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.informationLabel.frame), CGRectGetWidth(self.view.bounds), 53)];
    self.textField.alpha = 0;
    self.textField.font = [UIFont fontWithName:kFontNameSystemMedium size:18];
    self.textField.textColor = [UIColor colorWithRed:0.0/255.f green:135/255.f blue:43/255.f alpha:1.00];
    self.textField.textAlignment = NSTextAlignmentCenter;
    self.textField.delegate = self;
    [self.view addSubview:self.textField];
    
    self.textFieldBackground = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.textField.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.textField.frame))];
    self.textFieldBackground.backgroundColor = [UIColor whiteColor];
    self.textFieldBackground.alpha = 0;
    [self.view insertSubview:self.textFieldBackground belowSubview:self.textField];
    
    self.hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.textField.frame), CGRectGetWidth(self.view.bounds) - 40, 0)];
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    self.hintLabel.font = [UIFont fontWithName:kFontNameSystemLight size:15];
    self.hintLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    self.hintLabel.numberOfLines = 0;
    self.hintLabel.alpha = 0;
    self.hintLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.hintLabel];

    self.importProfileImageOptionsView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 216, self.view.width, 216)];
    self.importProfileImageOptionsView.backgroundColor = [UIColor colorWithRed:0.92 green:0.97 blue:0.91 alpha:1];
    self.importProfileImageOptionsView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.importProfileImageOptionsView.hidden = YES;
    [self.view addSubview:self.importProfileImageOptionsView];
    
    UIButton *albunsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.importProfileImageOptionsView.width, self.importProfileImageOptionsView.height / 2)];
    albunsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    albunsButton.imageEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
    albunsButton.titleEdgeInsets = UIEdgeInsetsMake(0, 45, 0, 0);
    [albunsButton setTitle:NSLocalizedString(@"Choose from my albums", @"") forState:UIControlStateNormal];
    [albunsButton setImage:[UIImage imageNamed:@"signup_icon_importlibrary"] forState:UIControlStateNormal];
    [albunsButton setTitleColor:[UIColor ftb_greenGrassColor] forState:UIControlStateNormal];
    [albunsButton setTitleColor:[UIColor colorWithRed:0.04 green:0.35 blue:0.16 alpha:1] forState:UIControlStateHighlighted];
    [albunsButton addTarget:self action:@selector(importFromPhotoLibraryAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.importProfileImageOptionsView addSubview:albunsButton];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(18, CGRectGetMaxY(albunsButton.frame) - 0.5, albunsButton.width - 38, 1)];
    separatorView.backgroundColor = [UIColor colorWithRed:0.74 green:0.9 blue:0.78 alpha:1];
    [self.importProfileImageOptionsView addSubview:separatorView];
    
    UIButton *facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(albunsButton.frame), albunsButton.width, albunsButton.height)];
    facebookButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    facebookButton.imageEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
    facebookButton.titleEdgeInsets = UIEdgeInsetsMake(0, 45, 0, 0);
    [facebookButton setTitle:NSLocalizedString(@"Import from Facebook", @"") forState:UIControlStateNormal];
    [facebookButton setImage:[UIImage imageNamed:@"signup_icon_importfb"] forState:UIControlStateNormal];
    [facebookButton setTitleColor:[UIColor ftb_greenGrassColor] forState:UIControlStateNormal];
    [facebookButton setTitleColor:[UIColor colorWithRed:0.04 green:0.35 blue:0.16 alpha:1] forState:UIControlStateHighlighted];
    [facebookButton addTarget:self action:@selector(importFromFacebookAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.importProfileImageOptionsView addSubview:facebookButton];
    
    BOOL shouldAnimate = self.navigationController.viewControllers.firstObject != self;
    if (!shouldAnimate) {
        [self.textField becomeFirstResponder];
    }
    
    [UIView animateWithDuration:shouldAnimate ? FTBAnimationDuration : 0 animations:^{
        signupImageView.alpha = 1;
    } completion:^(BOOL finished) {
        self.statusBarVisible = YES;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self setNeedsStatusBarAppearanceUpdate];
        
        [UIView animateWithDuration:shouldAnimate ? FTBAnimationDuration : 0 animations:^{
            self.textFieldBackground.alpha = 1;
            self.textField.alpha = 1;
            self.hintLabel.alpha = 1;
            self.informationLabel.alpha = 1;
        } completion:^(BOOL finished) {
            [self.textField becomeFirstResponder];
        }];
    }];
    
    self.profileImageButton = [[UIButton alloc] initWithFrame:CGRectMake(85, 97, 150, 150)];
    self.profileImageButton.midX = self.view.width / 2;
    self.profileImageButton.alpha = 0;
    self.profileImageButton.backgroundColor = [UIColor whiteColor];
    self.profileImageButton.layer.cornerRadius = self.profileImageButton.height / 2;
    self.profileImageButton.clipsToBounds = YES;
    self.profileImageButton.contentMode = UIViewContentModeScaleAspectFill;
    self.profileImageButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.profileImageButton setImage:[UIImage imageNamed:@"signup_icon_photo"] forState:UIControlStateNormal];
    [self.profileImageButton addTarget:self action:@selector(importFromCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.profileImageButton];
    
    if (self.view.height > 500) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicatorView.center = CGPointMake(CGRectGetMidX(self.textFieldBackground.frame), CGRectGetMidY(self.textFieldBackground.frame) + self.activityIndicatorView.height + 30);
    } else {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicatorView.center = CGPointMake(self.textFieldBackground.width - 40, CGRectGetMidY(self.textFieldBackground.frame));
    }
    self.activityIndicatorView.hidesWhenStopped = YES;
    self.activityIndicatorView.accessibilityLabel = NSLocalizedString(@"Loading", @"Loading");
    [self.view addSubview:self.activityIndicatorView];
    
    [self reloadTextField];
}

@end
