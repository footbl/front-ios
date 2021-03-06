//
//  LoginViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/7/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "LoginViewController.h"
#import "FTBClient.h"
#import "NSString+Validations.h"
#import "UILabel+Shake.h"

@interface LoginViewController ()

@property (assign, nonatomic) BOOL statusBarVisible;

@end

static NSString * kCachedEmailKey = @"kCachedEmailKey";

#pragma mark LoginViewController

@implementation LoginViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

+ (void)setEmail:(NSString *)email {
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:kCachedEmailKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

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
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(FTBAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:NO];
    });
}

- (IBAction)loginAction:(id)sender {
    self.view.userInteractionEnabled = NO;
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    [[FTBClient client] loginWithEmail:self.emailTextField.text password:self.passwordTextField.text success:^(id response) {
        if (self.completionBlock) self.completionBlock();
    } failure:^(NSError *error) {
        self.view.userInteractionEnabled = YES;
        [self.passwordTextField becomeFirstResponder];
        [[ErrorHandler sharedInstance] displayError:error];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        if (textField.text.isEmail) {
            [self.passwordTextField becomeFirstResponder];
        } else {
            [textField shakeAndChangeColor];
            return NO;
        }
    } else if (textField == self.passwordTextField) {
        if (textField.text.isValidPassword) {
            [self loginAction:textField];
        } else {
            [textField shakeAndChangeColor];
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.navigationItem.rightBarButtonItem.enabled = self.emailTextField.text.isEmail && self.passwordTextField.text.isValidPassword;
    });
    
    return YES;
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Continue", @"") style:UIBarButtonItemStylePlain target:self action:@selector(loginAction:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.title = NSLocalizedString(@"Sign in", @"");
    
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
    
    self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(70, CGRectGetMaxY(self.informationLabel.frame), CGRectGetWidth(self.view.bounds) - 80, 53)];
    self.emailTextField.alpha = 0;
    self.emailTextField.font = [UIFont fontWithName:kFontNameSystemMedium size:18];
    self.emailTextField.textColor = [UIColor colorWithRed:0.0/255.f green:135/255.f blue:43/255.f alpha:1.00];
    self.emailTextField.textAlignment = NSTextAlignmentLeft;
    self.emailTextField.delegate = self;
    self.emailTextField.secureTextEntry = NO;
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailTextField.returnKeyType = UIReturnKeyNext;
    self.emailTextField.enablesReturnKeyAutomatically = YES;
    self.emailTextField.placeholder = NSLocalizedString(@"Email placeholder", @"");
    self.emailTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:kCachedEmailKey];
    [self.view addSubview:self.emailTextField];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedEmailKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.emailIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signup_user_icon_off"]];
    self.emailIconImageView.center = CGPointMake(CGRectGetMinX(self.emailTextField.frame) - 30, CGRectGetMidY(self.emailTextField.frame));
    self.emailIconImageView.alpha = 0;
    [self.view addSubview:self.emailIconImageView];
    
    UIView *emailTextFieldBackground = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.emailTextField.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.emailTextField.frame))];
    emailTextFieldBackground.backgroundColor = [UIColor whiteColor];
    emailTextFieldBackground.alpha = 0;
    [self.view insertSubview:emailTextFieldBackground belowSubview:self.emailTextField];
    
    self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.emailTextField.frame), CGRectGetMaxY(self.emailTextField.frame) + 10, CGRectGetWidth(self.emailTextField.frame), CGRectGetHeight(self.emailTextField.frame))];
    self.passwordTextField.alpha = 0;
    self.passwordTextField.font = [UIFont fontWithName:kFontNameSystemMedium size:18];
    self.passwordTextField.textColor = [UIColor colorWithRed:0.0/255.f green:135/255.f blue:43/255.f alpha:1.00];
    self.passwordTextField.textAlignment = NSTextAlignmentLeft;
    self.passwordTextField.delegate = self;
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.returnKeyType = UIReturnKeyDone;
    self.passwordTextField.enablesReturnKeyAutomatically = YES;
    self.passwordTextField.placeholder = NSLocalizedString(@"Password placeholder", @"");
    [self.view addSubview:self.passwordTextField];
    
    self.passwordIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"register_pass_icon_off"]];
    self.passwordIconImageView.center = CGPointMake(CGRectGetMinX(self.passwordTextField.frame) - 30, CGRectGetMidY(self.passwordTextField.frame));
    self.passwordIconImageView.alpha = 0;
    [self.view addSubview:self.passwordIconImageView];
    
    UIView *passwordTextFieldBackground = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.passwordTextField.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.passwordTextField.frame))];
    passwordTextFieldBackground.backgroundColor = [UIColor whiteColor];
    passwordTextFieldBackground.alpha = 0;
    [self.view insertSubview:passwordTextFieldBackground belowSubview:self.passwordTextField];
    
    BOOL shouldAnimate = self.navigationController.viewControllers.firstObject != self;
    if (!shouldAnimate) {
        [self.emailTextField becomeFirstResponder];
    }
    
    [UIView animateWithDuration:shouldAnimate ? FTBAnimationDuration : 0 animations:^{
        signupImageView.alpha = 1;
    } completion:^(BOOL finished) {
        self.statusBarVisible = YES;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self setNeedsStatusBarAppearanceUpdate];
        
        [UIView animateWithDuration:shouldAnimate ? FTBAnimationDuration : 0 animations:^{
            emailTextFieldBackground.alpha = 1;
            passwordTextFieldBackground.alpha = 1;
            self.emailTextField.alpha = 1;
            self.emailIconImageView.alpha = 1;
            self.passwordTextField.alpha = 1;
            self.passwordIconImageView.alpha = 1;
            self.informationLabel.alpha = 1;
        } completion:^(BOOL finished) {
            [self.emailTextField becomeFirstResponder];
        }];
    }];
    
    NSString *text = NSLocalizedString(@"Login text: welcome back", @"");
    if (text) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
        if ([text rangeOfString:@"\n"].location != NSNotFound) {
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[text componentsSeparatedByString:@"\n"].firstObject attributes:[self informationTitleTextAttributes]]];
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[text componentsSeparatedByString:@"\n"].lastObject attributes:[self informationBodyTextAttributes]]];
        } else {
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:text attributes:[self informationBodyTextAttributes]]];
        }
        
        self.informationLabel.attributedText = attributedString;
    }
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
