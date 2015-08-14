//
//  ChangePasswordViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/26/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "FTAuthenticationManager.h"
#import "LoadingHelper.h"
#import "NSString+Validations.h"
#import "UILabel+Shake.h"
#import "UIView+Frame.h"

@interface ChangePasswordViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UIView *textFieldBackground;

@end

#pragma mark ChangePasswordViewController

@implementation ChangePasswordViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)signupAction:(id)sender {
    self.view.userInteractionEnabled = NO;
    [self.textField resignFirstResponder];
    
    [[LoadingHelper sharedInstance] showHud];
    
    [[FTAuthenticationManager sharedManager] updateUserWithUsername:nil name:nil email:nil password:self.password fbToken:nil profileImage:nil about:nil success:^(id response) {
        [[LoadingHelper sharedInstance] hideHud];
        if (self.completionBlock) self.completionBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[LoadingHelper sharedInstance] hideHud];
        self.view.userInteractionEnabled = YES;
        [self.textField becomeFirstResponder];
        [[ErrorHandler sharedInstance] displayError:error];
    }];
}

- (IBAction)continueAction:(id)sender {
    void(^switchInputBlock)() = ^() {
        self.hintLabel.text = @"";
        [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] animations:^{
            self.informationLabel.alpha = 0;
            self.textField.alpha = 0;
            self.hintLabel.alpha = 0;
        } completion:^(BOOL finished) {
            self.textField.text = @"";
            [self reloadTextField];
            [self.textField resignFirstResponder];
            [self.textField becomeFirstResponder];
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
    
    if (!self.oldPassword) {
        if ([[FTAuthenticationManager sharedManager] isValidPassword:self.textField.text]) {
            self.oldPassword = self.textField.text;
            switchInputBlock();
        } else {
            invalidInputBlock();
        }
    } else if (self.textField.text.isValidPassword) {
        self.password = self.textField.text;
        [self signupAction:sender];
    } else {
        invalidInputBlock();
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

- (void)showHint {
    if (!self.oldPassword) {
        self.hintLabel.text = NSLocalizedString(@"Change password text: old password hint", @"");
    } else if (!self.password) {
        self.hintLabel.text = NSLocalizedString(@"Change password text: new password hint", @"");
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
    
    if (!self.oldPassword) {
        text = NSLocalizedString(@"Change password text: insert old password", @"");
        
        self.textField.secureTextEntry = NO;
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.returnKeyType = UIReturnKeyNext;
        self.textField.enablesReturnKeyAutomatically = YES;
    } else if (!self.password) {
        text = NSLocalizedString(@"Change password text: insert new password", @"");
        
        self.textField.secureTextEntry = NO;
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.returnKeyType = UIReturnKeyDone;
        self.textField.enablesReturnKeyAutomatically = YES;
    }
    
    if (text && [text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0) {
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
    
    self.title = NSLocalizedString(@"Change password", @"");
    
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
    signupImageView.alpha = 1;
    [self.view addSubview:signupImageView];
    
    self.informationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 93, CGRectGetWidth(self.view.bounds), 112)];
    self.informationLabel.numberOfLines = 0;
    self.informationLabel.alpha = 1;
    [self.view addSubview:self.informationLabel];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.informationLabel.frame), CGRectGetWidth(self.view.bounds), 53)];
    self.textField.alpha = 1;
    self.textField.font = [UIFont fontWithName:kFontNameSystemMedium size:18];
    self.textField.textColor = [UIColor colorWithRed:0.0/255.f green:135/255.f blue:43/255.f alpha:1.00];
    self.textField.textAlignment = NSTextAlignmentCenter;
    self.textField.delegate = self;
    [self.view addSubview:self.textField];
    
    self.textFieldBackground = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.textField.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.textField.frame))];
    self.textFieldBackground.backgroundColor = [UIColor whiteColor];
    self.textFieldBackground.alpha = 1;
    [self.view insertSubview:self.textFieldBackground belowSubview:self.textField];
    
    self.hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.textField.frame), CGRectGetWidth(self.view.bounds) - 40, 0)];
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    self.hintLabel.font = [UIFont fontWithName:kFontNameSystemLight size:15];
    self.hintLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    self.hintLabel.numberOfLines = 0;
    self.hintLabel.alpha = 1;
    self.hintLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.hintLabel];
    
    [self.textField becomeFirstResponder];
    
    [self reloadTextField];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
