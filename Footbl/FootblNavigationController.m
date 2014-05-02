//
//  FootblNavigationController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "FootblNavigationController.h"

@interface FootblNavigationController ()

@end

#pragma mark FootblNavigationController

@implementation FootblNavigationController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

#pragma mark - Delegates & Data sources

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.navigationBar.barTintColor = [FootblAppearance colorForView:FootblColorNavigationBar];
    
    NSDictionary *titleAttributes = @{NSFontAttributeName : [UIFont fontWithName:kFontNameAvenirNextDemiBold size:16],
                                      NSForegroundColorAttributeName : [UIColor ftGreenGrassColor]};
    [UINavigationBar appearanceWhenContainedIn:[self class], nil].titleTextAttributes = titleAttributes;
    [UINavigationBar appearanceWhenContainedIn:[self class], nil].tintColor = [[UIColor ftGreenGrassColor] colorWithAlphaComponent:0.7];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.navigationBar.frame), CGRectGetWidth(self.navigationBar.frame), 0.5)];
    separatorView.backgroundColor = [FootblAppearance colorForView:FootblColorNavigationBarSeparator];
    separatorView.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.navigationBar addSubview:separatorView];
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
