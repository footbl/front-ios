//
//  SeasonWelcomePopupViewController.m
//  Footbl
//
//  Created by Leonardo Formaggio on 9/27/15.
//  Copyright © 2015 Footbl. All rights reserved.
//

#import "SeasonWelcomePopupViewController.h"
#import "FTBSeason.h"

@implementation SeasonWelcomePopupViewController

+ (NSString *)storyboardName {
    return @"Main";
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.welcomeLabel.text = NSLocalizedString(@"Welcome to", nil);
    self.seasonLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Season %@", nil), self.season.title];
    self.offeredLabel.text = NSLocalizedString(@"Offered by", nil);
    self.walletMessageLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Your wallet will reset to $100 %@", nil), @(self.season.daysToResetWallet)];
    [self.okButton setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {}

- (IBAction)ok:(id)sender {
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
