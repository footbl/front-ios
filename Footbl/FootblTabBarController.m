//
//  FootblTabBarController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "FootblNavigationController.h"
#import "FootblTabBarController.h"
#import "GroupsViewController.h"
#import "MatchesViewController.h"
#import "ProfileViewController.h"

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
    
    [UIView animateWithDuration:animated ? [FootblAppearance speedForAnimation:FootblAnimationTabBar] : 0 animations:^{
        CGRect tabBarFrame = self.tabBar.frame;
        if (self.isTabBarHidden) {
            tabBarFrame.origin.y = CGRectGetHeight(self.view.frame);
        } else {
            tabBarFrame.origin.y = CGRectGetHeight(self.view.frame) - CGRectGetHeight(tabBarFrame);
        }
        CGRect viewControllerFrame = self.selectedViewController.view.frame;
        viewControllerFrame.size.height = tabBarFrame.origin.y;
        self.tabBar.frame = tabBarFrame;
    }];
}

#pragma mark - Delegates & Data sources

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    FootblNavigationController *matchesNavigationController = [[FootblNavigationController alloc] initWithRootViewController:[MatchesViewController new]];
    FootblNavigationController *groupsNavigationController = [[FootblNavigationController alloc] initWithRootViewController:[GroupsViewController new]];
    FootblNavigationController *profileNavigationController = [[FootblNavigationController alloc] initWithRootViewController:[ProfileViewController new]];
    self.viewControllers = @[groupsNavigationController, matchesNavigationController, profileNavigationController];
    self.selectedIndex = 1;
    self.tabBar.barTintColor = [FootblAppearance colorForView:FootblColorTabBar];
    self.tabBar.tintColor = [FootblAppearance colorForView:FootblColorTabBarTint];
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
