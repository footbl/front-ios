//
//  TweaksHelper.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/23/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "BetsViewController.h"
#import "DailyBonusPopupViewController.h"
#import "ForceUpdateViewController.h"
#import "RatingHelper.h"
#import "RechargeTipPopupViewController.h"
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
    
    FBTweakAction(@"Actions", @"Recharge tip", @"Show popup", ^{
        UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        [viewController dismissViewControllerAnimated:YES completion:^{
            RechargeTipPopupViewController *rechargeTipPopup = [RechargeTipPopupViewController new];
            rechargeTipPopup.selectionBlock = ^{
                UITabBarController *tabBarController = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                BetsViewController *betsViewController = [[tabBarController.viewControllers[1] viewControllers] firstObject];
                [betsViewController rechargeWalletAction:nil];
            };
            FootblPopupViewController *popupViewController = [[FootblPopupViewController alloc] initWithRootViewController:rechargeTipPopup];
            [viewController presentViewController:popupViewController animated:YES completion:nil];
            [viewController setNeedsStatusBarAppearanceUpdate];
        }];
    });
    
    FBTweakAction(@"Actions", @"Daily Bonus", @"Show popup", ^{
        UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        [viewController dismissViewControllerAnimated:YES completion:^{
            DailyBonusPopupViewController *dailyBonusPopup = [DailyBonusPopupViewController new];
            FootblPopupViewController *popupViewController = [[FootblPopupViewController alloc] initWithRootViewController:dailyBonusPopup];
            [viewController presentViewController:popupViewController animated:YES completion:nil];
            [viewController setNeedsStatusBarAppearanceUpdate];
        }];
    });
}

@end
