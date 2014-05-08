//
//  SignupViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/8/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "FootblAPI.h"
#import "NSString+Validations.h"
#import "SignupViewController.h"
#import "UILabel+Shake.h"

@interface SignupViewController ()

@property (assign, nonatomic) BOOL statusBarVisible;

@end

#pragma mark SignupViewController

@implementation SignupViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (IBAction)cancelAction:(id)sender {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.statusBarVisible = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self setSubviewsHidden:YES animated:YES];
    [self.textField resignFirstResponder];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([FootblAppearance speedForAnimation:FootblAnimationDefault] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:NO];
    });
}

- (IBAction)signupAction:(id)sender {
    FootblAPIFailureBlock failureBlock = ^(NSError *error) {
        if (error) {
            self.view.userInteractionEnabled = YES;
            [self.textField becomeFirstResponder];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
            [alert show];
        }
    };
    
    self.view.userInteractionEnabled = NO;
    [self.textField resignFirstResponder];
    
    [[FootblAPI sharedAPI] createAccountWithSuccess:^{
        [[FootblAPI sharedAPI] updateAccountWithUsername:self.username email:self.email password:self.password success:^{
            if (self.completionBlock) self.completionBlock();
        } failure:failureBlock];
    } failure:failureBlock];
}

- (IBAction)continueAction:(id)sender {
    void(^switchInputBlock)() = ^() {
        self.hintLabel.text = @"";
        [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] animations:^{
            self.informationLabel.alpha = 0;
            self.textField.alpha = 0;
            self.hintLabel.alpha = 0;
        } completion:^(BOOL finished) {
            [self reloadTextField];
            self.textField.text = @"";
            [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] animations:^{
                self.informationLabel.alpha = 1;
                self.textField.alpha = 1;
                self.hintLabel.alpha = 1;
            }];
        }];
    };
    
    void(^invalidInputBlock)() = ^() {
        [self showHint];
        [self.textField shakeAndChangeColor];
    };
    
    if (!self.email) {
        if (self.textField.text.isEmail) {
            self.email = [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            switchInputBlock();
        } else {
            invalidInputBlock();
        }
    } else if (!self.password) {
        if (self.textField.text.isValidPassword) {
            self.password = self.textField.text;
            switchInputBlock();
        } else {
            invalidInputBlock();
        }
    } else if (!self.passwordConfirmation) {
        if ([self.textField.text isEqualToString:self.password]) {
            self.passwordConfirmation = self.textField.text;
            switchInputBlock();
        } else {
            invalidInputBlock();
        }
    } else if (!self.username) {
        if (self.textField.text.isValidUsername) {
            self.username = self.textField.text;
            [self signupAction:self.textField];
        } else {
            invalidInputBlock();
        }
    }
}

- (void)setSubviewsHidden:(BOOL)hidden animated:(BOOL)animated {
    [UIView animateWithDuration:animated ? [FootblAppearance speedForAnimation:FootblAnimationDefault] : 0 animations:^{
        for (UIView *view in self.view.subviews) {
            if (view != self.backgroundImageView) {
                view.alpha = !hidden;
            }
        }
    }];
}

- (BOOL)prefersStatusBarHidden {
    return !self.statusBarVisible;
}

- (void)showHint {
    if (!self.email) {
        self.hintLabel.text = NSLocalizedString(@"Sign up text: email hint", @"");
    } else if (!self.password) {
        self.hintLabel.text = NSLocalizedString(@"Sign up text: password hint", @"");
    } else if (!self.passwordConfirmation) {
        self.hintLabel.text = NSLocalizedString(@"Sign up text: password confirmation hint", @"");
    } else if (!self.username) {
        self.hintLabel.text = NSLocalizedString(@"Sign up text: username hint", @"");
    }
    
    CGRect frame = self.hintLabel.frame;
    frame.size.height = [self.hintLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.hintLabel.frame), INT_MAX)].height + 20;
    self.hintLabel.frame = frame;
    if (self.hintLabel.text.length == 0) {
        self.hintLabel.alpha = 0;
    }
    [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] animations:^{
        self.hintLabel.alpha = 1;
    }];
}

- (void)reloadTextField {
    NSString *text;
    if (!self.email) {
        text = NSLocalizedString(@"Sign up text: email", @"");
        
        self.textField.secureTextEntry = NO;
        self.textField.keyboardType = UIKeyboardTypeEmailAddress;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.returnKeyType = UIReturnKeyNext;
        self.textField.enablesReturnKeyAutomatically = YES;
    } else if (!self.password) {
        text = NSLocalizedString(@"Sign up text: password", @"");
        
        self.textField.secureTextEntry = YES;
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.returnKeyType = UIReturnKeyNext;
        self.textField.enablesReturnKeyAutomatically = YES;
    } else if (!self.passwordConfirmation) {
        text = NSLocalizedString(@"Sign up text: password confirmation", @"");
        
        self.textField.secureTextEntry = YES;
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.returnKeyType = UIReturnKeyNext;
        self.textField.enablesReturnKeyAutomatically = YES;
    } else if (!self.username) {
        text = NSLocalizedString(@"Sign up text: username", @"");
        
        self.textField.secureTextEntry = NO;
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.returnKeyType = UIReturnKeyDone;
        self.textField.enablesReturnKeyAutomatically = YES;
    }
    
    if (text) {
        NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
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

#pragma mark - UITextField delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] animations:^{
        self.hintLabel.alpha = 0;
    }];
    
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
    self.backgroundImageView.contentMode = UIViewContentModeTop;
    [self.view addSubview:self.backgroundImageView];
    
    UIImageView *signupImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    signupImageView.image = [UIImage imageNamed:@"signup_step2_bg"];
    signupImageView.contentMode = UIViewContentModeTop;
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
    
    UIView *textFieldBackground = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.textField.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.textField.frame))];
    textFieldBackground.backgroundColor = [UIColor whiteColor];
    textFieldBackground.alpha = 0;
    [self.view insertSubview:textFieldBackground belowSubview:self.textField];
    
    self.hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.textField.frame), CGRectGetWidth(self.view.bounds) - 40, 0)];
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    self.hintLabel.font = [UIFont fontWithName:kFontNameSystemLight size:15];
    self.hintLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    self.hintLabel.numberOfLines = 0;
    self.hintLabel.alpha = 0;
    self.hintLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.hintLabel];
    
    [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] animations:^{
        signupImageView.alpha = 1;
    } completion:^(BOOL finished) {
        self.statusBarVisible = YES;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self setNeedsStatusBarAppearanceUpdate];
        
        [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] animations:^{
            textFieldBackground.alpha = 1;
            self.textField.alpha = 1;
            self.hintLabel.alpha = 1;
            self.informationLabel.alpha = 1;
        } completion:^(BOOL finished) {
            [self.textField becomeFirstResponder];
        }];
    }];
    
    [self reloadTextField];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
