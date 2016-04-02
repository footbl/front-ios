//
//  FootblTabBarController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "AuthenticationViewController.h"
#import "BetsViewController.h"
#import "FootblNavigationController.h"
#import "FootblTabBarController.h"
#import "ForceUpdateViewController.h"
#import "GroupsViewController.h"
#import "MatchesViewController.h"
#import "ProfileViewController.h"
#import "TutorialViewController.h"
#import "FavoritesViewController.h"
#import "MyChallengesViewController.h"

#import "FTBClient.h"
#import "FTBConstants.h"
#import "FTBUser.h"

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
        CGRect tabBarFrame = self.tabBar.frame;
        if (self.isTabBarHidden) {
            tabBarFrame.origin.y = CGRectGetHeight(self.view.frame) + 0.5;
        } else {
            tabBarFrame.origin.y = CGRectGetHeight(self.view.frame) - CGRectGetHeight(tabBarFrame);
        }
        CGRect viewControllerFrame = self.selectedViewController.view.frame;
        viewControllerFrame.size.height = tabBarFrame.origin.y + CGRectGetHeight(tabBarFrame);
        self.selectedViewController.view.frame = viewControllerFrame;
        self.tabBar.frame = tabBarFrame;
        
        CGRect separatorFrame = self.tabBarSeparatorView.frame;
        separatorFrame.origin.y = CGRectGetMinY(tabBarFrame) - 0.5;
        self.tabBarSeparatorView.frame = separatorFrame;
    }];
}

#pragma mark - Delegates & Data sources

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    void(^viewControllersSetupBlock)() = ^() {
        GroupsViewController *groupsViewController = [[GroupsViewController alloc] init];
        FootblNavigationController *groupsNavigationController = [[FootblNavigationController alloc] initWithRootViewController:groupsViewController];
        
        MyChallengesViewController *challengesViewController = [MyChallengesViewController instantiateFromStoryboard];
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
                navigationController = [FootblNavigationController new];
                [self presentViewController:navigationController animated:NO completion:nil];
            }
            
            AuthenticationViewController *authenticationViewController = [AuthenticationViewController new];
            [navigationController setViewControllers:@[authenticationViewController] animated:YES];
            authenticationViewController.completionBlock = ^{
                viewControllersSetupBlock();
                [self dismissViewControllerAnimated:YES completion:nil];
            };
        }
    };
    
    self.viewControllers = @[[UIViewController new]];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if ([TutorialViewController shouldPresentTutorial]) {
            TutorialViewController *tutorialViewController = [TutorialViewController new];
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
            AuthenticationViewController *authenticationViewController = [AuthenticationViewController new];
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
            [viewController presentViewController:[ForceUpdateViewController new] animated:YES completion:nil];
        }
    }];
    
    self.tabBar.barTintColor = [UIColor ftb_tabBarColor];
    self.tabBar.tintColor = [UIColor ftb_tabBarTintColor];
    
    self.tabBarSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.tabBar.frame) - 0.5, CGRectGetWidth(self.tabBar.frame), 0.5)];
    self.tabBarSeparatorView.backgroundColor = [UIColor ftb_tabBarSeparatorColor];
    self.tabBarSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.tabBarSeparatorView];
}

@end
