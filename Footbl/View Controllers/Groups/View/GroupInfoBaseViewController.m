//
//  GroupInfoBaseViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/3/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "GroupInfoBaseViewController.h"
#import "ImportImageHelper.h"
#import "UIView+Frame.h"
#import "UIView+Shake.h"

@interface GroupInfoBaseViewController ()

@property (assign, nonatomic) CGRect nameOriginalFrame;

@end

#pragma mark GroupInfoBaseViewController

@implementation GroupInfoBaseViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (IBAction)selectImageAction:(id)sender {
    BOOL keyboardIsFirstResponder = self.nameTextField.isFirstResponder;
    [self.nameTextField resignFirstResponder];
    [[ImportImageHelper sharedInstance] importImageFromSources:@[@(ImportImageHelperSourceCamera), @(ImportImageHelperSourceLibrary)] completionBlock:^(UIImage *image, NSError *error) {
        if (image) {
            [self.groupImageButton setImage:image forState:UIControlStateNormal];
        }
        if (keyboardIsFirstResponder) {
            [self.nameTextField becomeFirstResponder];
        }
    }];
}

- (void)updateLimitTextForLength:(NSInteger)length {
    switch (length) {
        case 1:
            self.nameSizeLimitLabel.text = NSLocalizedString(@"1 character left", @"");
            break;
        case MAX_GROUP_NAME_SIZE:
            self.nameSizeLimitLabel.text = NSLocalizedString(@"Insert group name", @"");
            break;
        default:
            self.nameSizeLimitLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%i characters left", @"{number of characters} characters left"), length];
            break;
    }
}

- (void)shakeLimitLabel {
    UIColor *originalColor = [UIColor colorWithRed:184/255.f green:191/255.f blue:186/255.f alpha:1.00];
    [self.nameSizeLimitLabel shake];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.1f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.nameSizeLimitLabel.layer addAnimation:transition forKey:nil];
    self.nameSizeLimitLabel.textColor = [UIColor colorWithRed:216/255.f green:80./255.f blue:80./255.f alpha:1.00];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CATransition *transition = [CATransition animation];
        transition.duration = 0.2f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        [self.nameSizeLimitLabel.layer addAnimation:transition forKey:nil];
        self.nameSizeLimitLabel.textColor = originalColor;
    });
}

#pragma mark - Delegates & Data sources

#pragma mark - UITextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self updateLimitTextForLength:MAX_GROUP_NAME_SIZE - self.nameTextField.text.length];
    
    self.nameOriginalFrame = self.nameTextField.frame;
    
    [UIView animateWithDuration:FTBAnimationDuration animations:^{
        self.nameSizeLimitLabel.alpha = 1.0;
        self.nameTextField.y -= 2;
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSInteger size = MAX_GROUP_NAME_SIZE - [self.nameTextField.text stringByReplacingCharactersInRange:range withString:string].length;
    if (size < 0) {
        [self shakeLimitLabel];
        return NO;
    }
    
    [self updateLimitTextForLength:size];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:FTBAnimationDuration animations:^{
        self.nameSizeLimitLabel.alpha = 0;
        self.nameTextField.frame = self.nameOriginalFrame;
    }];
    
    [self.nameTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        [textField resignFirstResponder];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor ftb_viewMatchBackgroundColor];
    
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
    
    UIView *titleView = generateView(CGRectMake(0, 120, CGRectGetWidth(self.view.frame), 103));
    CGRect titleFrame = CGRectMake(CGRectGetMinX(titleView.frame), 145, CGRectGetWidth(titleView.frame), 53);
    titleFrame.origin.y += 5;
    self.nameTextField = [[UITextField alloc] initWithFrame:titleFrame];
    self.nameTextField.font = [UIFont fontWithName:kFontNameLight size:24];
    self.nameTextField.textAlignment = NSTextAlignmentCenter;
    self.nameTextField.textColor = [[UIColor ftb_cellMatchPotColor] colorWithAlphaComponent:1.0];
    self.nameTextField.delegate = self;
    [self.view addSubview:self.nameTextField];
    
    CGRect limitFrame = CGRectMake(CGRectGetMinX(titleFrame), 190, CGRectGetWidth(titleFrame), 23);
    self.nameSizeLimitLabel = [[UILabel alloc] initWithFrame:limitFrame];
    self.nameSizeLimitLabel.textAlignment = NSTextAlignmentCenter;
    self.nameSizeLimitLabel.font = [UIFont fontWithName:kFontNameAvenirNextRegular size:12];
    self.nameSizeLimitLabel.textColor = [UIColor colorWithRed:184/255.f green:191/255.f blue:186/255.f alpha:1.00];
    self.nameSizeLimitLabel.alpha = 0;
    [self.view addSubview:self.nameSizeLimitLabel];
    
    self.groupImageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    self.groupImageButton.center = CGPointMake(CGRectGetMidX(titleView.frame), CGRectGetMinY(titleView.frame));
    self.groupImageButton.layer.cornerRadius = CGRectGetHeight(self.groupImageButton.frame) / 2;
    self.groupImageButton.clipsToBounds = YES;
    self.groupImageButton.backgroundColor = [UIColor whiteColor];
    self.groupImageButton.titleLabel.font = [UIFont fontWithName:kFontNameMedium size:13];
    self.groupImageButton.titleLabel.numberOfLines = 2;
    self.groupImageButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.groupImageButton setTitle:NSLocalizedString(@"Add photo", @"") forState:UIControlStateNormal];
    [self.groupImageButton setTitleColor:[UIColor colorWithRed:141/255.f green:151/255.f blue:144/255.f alpha:1.00] forState:UIControlStateNormal];
    [self.groupImageButton setTitleColor:[[self.groupImageButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.20] forState:UIControlStateHighlighted];
    [self.groupImageButton addTarget:self action:@selector(selectImageAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.groupImageButton];
    
    self.groupImageButtonBorder = [[UIView alloc] initWithFrame:self.groupImageButton.frame];
    self.groupImageButtonBorder.layer.borderColor = titleView.layer.borderColor;
    self.groupImageButtonBorder.layer.borderWidth = 0.5;
    self.groupImageButtonBorder.layer.cornerRadius = self.groupImageButton.layer.cornerRadius;
    self.groupImageButtonBorder.userInteractionEnabled = NO;
    [self.view insertSubview:self.groupImageButtonBorder aboveSubview:self.groupImageButton];
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
