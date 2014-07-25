//
//  TweaksHelper.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/23/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "ForceUpdateViewController.h"
#import "RatingHelper.h"
#import "TweaksHelper.h"

#pragma mark TweaksHelper

@implementation TweaksHelper

#pragma mark - Class Methods

+ (void)load {
    [super load];
    
    FBTweakAction(@"Actions", @"Force update", @"Preview", ^{
        UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (viewController.presentedViewController) {
            viewController = viewController.presentedViewController;
        }
        [viewController presentViewController:[ForceUpdateViewController new] animated:YES completion:nil];
    });
    
    FBTweakAction(@"Actions", @"Review on App Store", @"Show alert", ^{
        [[RatingHelper sharedInstance] showAlert];
    });
}

@end
