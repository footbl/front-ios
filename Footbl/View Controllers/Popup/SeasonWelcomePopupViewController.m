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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {}

- (IBAction)ok:(id)sender {
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
