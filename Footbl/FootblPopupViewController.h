//
//  FootblPopupViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 7/30/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FootblPopupViewController : UIViewController

@property (strong, nonatomic) UIImageView *headerImageView;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController;
- (void)dismissViewController;

@end
