//
//  FootblPopupViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 7/30/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FootblPopupViewController : UIViewController

@property (strong, nonatomic) UIImageView *headerImageView;
@property (assign, nonatomic) CGRect frame;
@property (strong, nonatomic) UIColor *backgroundColor;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController;
- (void)dismissViewController;

@end
