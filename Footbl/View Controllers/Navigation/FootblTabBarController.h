//
//  FootblTabBarController.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FootblTabBarController : UITabBarController

@property (assign, nonatomic, getter = isTabBarHidden) BOOL tabBarHidden;
@property (strong, nonatomic) UIView *tabBarSeparatorView;

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;

@end
