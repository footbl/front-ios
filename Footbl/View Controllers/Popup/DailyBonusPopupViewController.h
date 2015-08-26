//
//  DailyBonusPopupViewController.h
//  Footbl
//
//  Created by Fernando Saragoca on 11/20/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "FootblPopupViewController.h"

@class FootblLabel;
@class FTBPrize;

@interface DailyBonusPopupViewController : FootblPopupViewController

@property (strong, nonatomic) UIButton *dismissButton;
@property (strong, nonatomic) FootblLabel *textLabel;
@property (strong, nonatomic) UIImageView *moneyImageView;
@property (strong, nonatomic) UILabel *moneySignLabel;
@property (strong, nonatomic) UILabel *moneyLabel;
@property (strong, nonatomic) FTBPrize *prize;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end
