//
//  FootblTabBarController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "FootblTabBarController.h"
#import "AuthenticationViewController.h"
#import "BetsViewController.h"
#import "ChallengesViewController.h"
#import "FavoritesViewController.h"
#import "FootblNavigationController.h"
#import "ForceUpdateViewController.h"
#import "FTBClient.h"
#import "FTBConstants.h"
#import "FTBUser.h"
#import "GroupsViewController.h"
#import "MatchesViewController.h"
#import "ProfileViewController.h"
#import "TutorialViewController.h"
#import "UIView+Frame.h"
#import "UIViewController+Addons.h"

@interface FootblTabBarController ()

@end

#pragma mark FootblTabBarController

@implementation FootblTabBarController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (void)setTabBarHidden:(BOOL)tabBarHidden {
    [self setTabBarHidden:tabBarHidden animated:NO];
}

#pragma mark - Instance Methods

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated {
    if (self.isTabBarHidden == hidden) {
        return;
    }
    
    _tabBarHidden = hidden;
    
    [UIView animateWithDuration:animated ? FTBAnimationDuration : 0 animations:^{
        self.tabBar.maxY = self.view.height + (hidden ? self.tabBar.height : 0);
    }];
}

#pragma mark - Delegates & Data sources

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    void(^viewControllersSetupBlock)() = ^() {
        GroupsViewController *groupsViewController = [[GroupsViewController alloc] init];
        FootblNavigationController *groupsNavigationController = [[FootblNavigationController alloc] initWithRootViewController:groupsViewController];
        
        ChallengesViewController *challengesViewController = [ChallengesViewController instantiateFromStoryboard];
        FootblNavigationController *challengesNavigationController = [[FootblNavigationController alloc] initWithRootViewController:challengesViewController];
        
        BetsViewController *betsViewController = [[BetsViewController alloc] init];
        FootblNavigationController *matchesNavigationController = [[FootblNavigationController alloc] initWithRootViewController:betsViewController];
        
        FavoritesViewController *favoritesViewController = [[FavoritesViewController alloc] init];
        favoritesViewController.user = [FTBUser currentUser];
        FootblNavigationController *favoritesNavigationController = [[FootblNavigationController alloc] initWithRootViewController:favoritesViewController];
        
        ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
        FootblNavigationController *profileNavigationController = [[FootblNavigationController alloc] initWithRootViewController:profileViewController];
        
        self.viewControllers = @[groupsNavigationController, challengesNavigationController, matchesNavigationController, favoritesNavigationController, profileNavigationController];
        self.selectedIndex = 2;
    };
    
    void(^authenticationBlock)(UINavigationController *navigationController) = ^(UINavigationController *navigationController) {
        if ([[FTBClient client] isAuthenticated]) {
            [self dismissViewControllerAnimated:YES completion:nil];
            viewControllersSetupBlock();
        } else {
            if (!navigationController) {
                navigationController = [[FootblNavigationController alloc] init];
                [self presentViewController:navigationController animated:NO completion:nil];
            }
            
            AuthenticationViewController *authenticationViewController = [[AuthenticationViewController alloc] init];
            [navigationController setViewControllers:@[authenticationViewController] animated:YES];
            authenticationViewController.completionBlock = ^{
                viewControllersSetupBlock();
                [self dismissViewControllerAnimated:YES completion:nil];
            };
        }
    };
    
    self.viewControllers = @[[[UIViewController alloc] init]];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if ([TutorialViewController shouldPresentTutorial]) {
            TutorialViewController *tutorialViewController = [[TutorialViewController alloc] init];
            FootblNavigationController *tutorialNavigationController = [[FootblNavigationController alloc] initWithRootViewController:tutorialViewController];
            [self presentViewController:tutorialNavigationController animated:NO completion:nil];
            [tutorialViewController setCompletionBlock:^{
                authenticationBlock(tutorialNavigationController);
            }];
        } else {
            authenticationBlock(nil);
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kFTNotificationAuthenticationChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if (![[FTBClient client] isAuthenticated]) {
            AuthenticationViewController *authenticationViewController = [[AuthenticationViewController alloc] init];
            FootblNavigationController *navigationController = [[FootblNavigationController alloc] initWithRootViewController:authenticationViewController];
            [self presentViewController:navigationController animated:YES completion:^{
                [(UINavigationController *)self.selectedViewController popToRootViewControllerAnimated:NO];
                self.selectedIndex = 1;
            }];
            authenticationViewController.completionBlock = ^{
                [navigationController dismissViewControllerAnimated:YES completion:nil];
            };
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kFTNotificationAPIOutdated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (viewController.presentedViewController) {
            viewController = viewController.presentedViewController;
        }
        if (![viewController isKindOfClass:[ForceUpdateViewController class]]) {
            [viewController presentViewController:[[ForceUpdateViewController alloc] init] animated:YES completion:nil];
        }
    }];
    
    self.tabBar.tintColor = [UIColor ftb_tabBarTintColor];
}

@end
