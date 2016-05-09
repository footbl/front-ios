//
//  FootblNavigationController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
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
    
    self.navigationBar.barTintColor = [UIColor ftb_navigationBarColor];
    
    NSDictionary *titleAttributes = @{NSFontAttributeName : [UIFont fontWithName:kFontNameAvenirNextDemiBold size:17],
                                      NSForegroundColorAttributeName : [UIColor ftb_greenGrassColor]};
    UINavigationBar *appearance = [UINavigationBar appearanceWhenContainedIn:[self class], nil];
    appearance.titleTextAttributes = titleAttributes;
    appearance.tintColor = [[UIColor ftb_greenGrassColor] colorWithAlphaComponent:0.7];
    [[UIBarButtonItem appearanceWhenContainedIn:[self class], nil] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:kFontNameMedium size:17]} forState:UIControlStateNormal];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.navigationBar.frame), CGRectGetWidth(self.navigationBar.frame), 0.5)];
    separatorView.backgroundColor = [UIColor ftb_navigationBarSeparatorColor];
    separatorView.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.navigationBar addSubview:separatorView];
}

@end
