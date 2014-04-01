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

#pragma mark - Instance Methods

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
