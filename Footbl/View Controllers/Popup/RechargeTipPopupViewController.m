//
//  RechargeTipPopupViewController.m
//  Footbl
//
//  Created by Fernando Saragoca on 11/20/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "RechargeTipPopupViewController.h"
#import "FootblLabel.h"
#import "FootblPopupViewController.h"
#import "FTBUser.h"
#import "RechargeButton.h"
#import "UIImage+Color.h"
#import "UIView+Frame.h"

@interface RechargeTipPopupViewController ()

@end

#pragma mark RechargeTipPopupViewController

static NSString * const kRechargeTipPopupDate = @"kRechargeTipPopupDate";
static NSUInteger const kRechargeTipTimeInterval = 60 * 60 * 24 * 3;

@implementation RechargeTipPopupViewController

#pragma mark - Class Methods

+ (BOOL)shouldBePresented {
	FTBUser *user = [FTBUser currentUser];
    NSDate *lastPresentedDate = [[NSUserDefaults standardUserDefaults] objectForKey:kRechargeTipPopupDate];
    if (user.canRecharge && (!lastPresentedDate || fabs([[NSDate date] timeIntervalSinceDate:lastPresentedDate]) > kRechargeTipTimeInterval)) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kRechargeTipPopupDate];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    return NO;
}

#pragma mark - Getters/Setters

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.textLabel.height = CGRectGetHeight(self.frame) - 50;
    self.headerImageView.y = CGRectGetHeight(self.frame) - 50;
}

#pragma mark - Instance Methods

- (IBAction)rechargeWalletAction:(id)sender {
    [self dismissViewController];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (float)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.selectionBlock) self.selectionBlock();
    });
}

#pragma mark - Protocols

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];
    // Do any additional setup after loading the view.
    
    self.textLabel = [[FootblLabel alloc] initWithFrame:CGRectMake(45, 0, self.view.width - 90, 95)];
    self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textLabel.textColor = [UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:1.00];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:18];
    self.textLabel.firstLineFont = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:22];
    self.textLabel.firstLineTextColor = [UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:1.00];
    self.textLabel.text = NSLocalizedString(@"Tip!\n\nRecharge your wallet by tapping the + above.", @"");
    [self.view addSubview:self.textLabel];
    
    self.dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
    self.dismissButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.dismissButton addTarget:self action:@selector(dismissViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.dismissButton setTitle:NSLocalizedString(@"OK", @"") forState:UIControlStateNormal];
    [self.dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.dismissButton setBackgroundImage:[UIImage imageWithColor:self.headerImageView.backgroundColor] forState:UIControlStateNormal];
    [self.dismissButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0.18 green:0.65 blue:0.39 alpha:1]] forState:UIControlStateHighlighted];
    [self.dismissButton.titleLabel setFont:[UIFont fontWithName:kFontNameAvenirNextDemiBold size:18]];
    self.headerImageView.userInteractionEnabled = YES;
    [self.headerImageView addSubview:self.dismissButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.rechargeButton = [[RechargeButton alloc] initWithFrame:CGRectMake(0, 0, 102, 80)];
    [self.rechargeButton setImage:[UIImage imageNamed:@"btn_recharge_money"] forState:UIControlStateNormal];
    [self.rechargeButton setImageEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 62)];
    self.rechargeButton.adjustsImageWhenDisabled = NO;
    self.rechargeButton.alpha = 0;
    [self.parentViewController.view.superview addSubview:self.rechargeButton];
    
    UIButton *button = [[UIButton alloc] initWithFrame:self.rechargeButton.frame];
    [button addTarget:self action:@selector(rechargeWalletAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.rechargeButton.superview addSubview:button];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.rechargeButton.alpha = 1;
    } completion:^(BOOL finished) {
        self.rechargeButton.animating = YES;
    }];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    [super willMoveToParentViewController:parent];
    
    if ([parent isKindOfClass:[FootblPopupViewController class]]) {
        self.frame = CGRectMake(20, ((self.view.height - 248) / 2) - 20, self.view.width - 40, 248);
        FootblPopupViewController *popupViewController = (FootblPopupViewController *)parent;
        popupViewController.frame = self.frame;
        popupViewController.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
