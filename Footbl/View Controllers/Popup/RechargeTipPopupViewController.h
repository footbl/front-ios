//
//  RechargeTipPopupViewController.h
//  Footbl
//
//  Created by Fernando Saragoca on 11/20/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "FootblPopupViewController.h"

@class FootblLabel;
@class RechargeButton;

@interface RechargeTipPopupViewController : FootblPopupViewController

@property (strong, nonatomic) UIButton *dismissButton;
@property (strong, nonatomic) FootblLabel *textLabel;
@property (strong, nonatomic) RechargeButton *rechargeButton;
@property (copy, nonatomic) void (^selectionBlock)();

+ (BOOL)shouldBePresented;

@end
