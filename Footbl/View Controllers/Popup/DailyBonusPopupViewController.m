//
//  DailyBonusPopupViewController.m
//  Footbl
//
//  Created by Fernando Saragoca on 11/20/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <SPHipster/UIView+Frame.h>

#import "DailyBonusPopupViewController.h"
#import "ErrorHandler.h"
#import "FootblLabel.h"
#import "FTBClient.h"
#import "FTBPrize.h"
#import "FTBUser.h"
#import "UIImage+Color.h"

@interface DailyBonusPopupViewController ()

- (BOOL)isDailyBonus;

@end

#pragma mark DailyBonusPopupViewController

@implementation DailyBonusPopupViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.textLabel.height = CGRectGetHeight(self.frame) - 50 - self.textLabel.y;
    self.headerImageView.y = CGRectGetHeight(self.frame) - 50;
    self.moneyImageView.x = (CGRectGetWidth(self.frame) - self.moneyImageView.width - self.moneyLabel.width) / 2;
    self.moneySignLabel.x = self.moneyImageView.x;
    self.activityIndicatorView.midX = (CGRectGetWidth(self.frame) / 2);
    
    CGFloat moneyWidth = self.moneySignLabel.width + self.moneyLabel.width;
    self.moneySignLabel.x = (CGRectGetWidth(frame) - moneyWidth) / 2;
    self.moneyLabel.x = self.moneySignLabel.x + self.moneySignLabel.width;
}

#pragma mark - Instance Methods

- (BOOL)isDailyBonus {
    return ((!self.prize && SPGetBuildType() != SPBuildTypeAppStore) || self.prize.type == FTBPrizeTypeDaily);
}

- (IBAction)collectAction:(id)sender {
    if (self.activityIndicatorView.isAnimating) {
        return;
    }
    
    self.dismissButton.userInteractionEnabled = NO;
    self.activityIndicatorView.alpha = 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.dismissButton.alpha = 0;
        self.activityIndicatorView.alpha = 1;
    }];
    
    [self.activityIndicatorView startAnimating];
    
    if (!self.prize && SPGetBuildType() != SPBuildTypeAppStore) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.activityIndicatorView stopAnimating];
            [self dismissViewController];
        });
        return;
    }
	
	[[FTBClient client] markPrizeAsRead:self.prize success:^(id object) {
		[self.activityIndicatorView stopAnimating];
		[self dismissViewController];
	} failure:^(NSError *error) {
		[[ErrorHandler sharedInstance] displayError:error];
		[UIView animateWithDuration:0.3 animations:^{
			self.dismissButton.alpha = 1;
			self.activityIndicatorView.alpha = 0;
		} completion:^(BOOL finished) {
			self.dismissButton.userInteractionEnabled = YES;
			[self.activityIndicatorView stopAnimating];
		}];
	}];
}

#pragma mark - Protocols

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];
    // Do any additional setup after loading the view.
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, self.view.width, 60)];
    headerLabel.font = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:22];
    headerLabel.textColor = [UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:1.00];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if (self.isDailyBonus) {
        headerLabel.text = NSLocalizedString(@"Daily bonus!", @"");
    } else {
        headerLabel.text = NSLocalizedString(@"Update bonus!", @"");
    }
    [self.view addSubview:headerLabel];
    
    self.moneyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 65, 50, 50)];
    self.moneyImageView.image = [UIImage imageNamed:@"money_sign"];
    self.moneyImageView.hidden = YES;
    [self.view addSubview:self.moneyImageView];
    
    self.moneySignLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, 50, 50)];
    self.moneySignLabel.clipsToBounds = YES;
    self.moneySignLabel.backgroundColor = self.headerImageView.backgroundColor;
    self.moneySignLabel.layer.cornerRadius = self.moneySignLabel.width / 2;
    self.moneySignLabel.textAlignment = NSTextAlignmentCenter;
    self.moneySignLabel.font = [UIFont systemFontOfSize:32];
    self.moneySignLabel.textColor = [UIColor whiteColor];
    self.moneySignLabel.text = NSLocalizedString(@"$", @"");
    [self.view addSubview:self.moneySignLabel];
    
    self.moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, 40, 50)];
    self.moneyLabel.textAlignment = NSTextAlignmentCenter;
    self.moneyLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:42];
    self.moneyLabel.textColor = self.headerImageView.backgroundColor;
    if (!self.prize && SPGetBuildType() != SPBuildTypeAppStore) {
        self.moneyLabel.text = [@1 stringValue];
    } else {
        self.moneyLabel.text = self.prize.value.stringValue;
    }
    self.moneyLabel.width = [self.moneyLabel sizeThatFits:CGSizeMake(INT_MAX, self.moneyLabel.height)].width;
    [self.view addSubview:self.moneyLabel];
    
    self.textLabel = [[FootblLabel alloc] initWithFrame:CGRectMake(10, 110, self.view.width - 20, 95)];
    self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textLabel.textColor = [UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:1.00];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:14];
    self.textLabel.firstLineFont = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:18];
    self.textLabel.firstLineTextColor = [UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:1.00];
    if (self.isDailyBonus) {
        self.textLabel.text = NSLocalizedString(@"Come back tomorrow for more\nEnjoy =)", @"");
    } else {
        self.textLabel.text = NSLocalizedString(@"We hope you like this update\nMake it count!", @"");
    }
    [self.view addSubview:self.textLabel];
    
    self.dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
    self.dismissButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.dismissButton addTarget:self action:@selector(collectAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.dismissButton setTitle:NSLocalizedString(@"Collect", @"") forState:UIControlStateNormal];
    [self.dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.dismissButton.titleLabel setFont:[UIFont fontWithName:kFontNameAvenirNextDemiBold size:18]];
    [self.dismissButton setBackgroundImage:[UIImage imageWithColor:self.headerImageView.backgroundColor] forState:UIControlStateNormal];
    [self.dismissButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0.18 green:0.65 blue:0.39 alpha:1]] forState:UIControlStateHighlighted];
    [self.dismissButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0.18 green:0.65 blue:0.39 alpha:1]] forState:UIControlStateDisabled];
    self.headerImageView.userInteractionEnabled = YES;
    [self.headerImageView addSubview:self.dismissButton];
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityIndicatorView.center = self.dismissButton.center;
    self.activityIndicatorView.hidesWhenStopped = YES;
    [self.headerImageView addSubview:self.activityIndicatorView];
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
