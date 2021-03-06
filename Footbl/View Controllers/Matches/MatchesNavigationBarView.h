//
//  MatchesNavigationBarView.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/23/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

@import UIKit;

@class RechargeButton;
@class ChampionshipsHeaderView;

extern NSString * const kMatchesNavigationBarTitleAnimateKey;

@interface MatchesNavigationBarView : UIView

@property (strong, nonatomic) RechargeButton *moneyButton;
@property (strong, nonatomic) UILabel *walletTitleLabel;
@property (strong, nonatomic) UILabel *walletValueLabel;
@property (strong, nonatomic) UILabel *stakeTitleLabel;
@property (strong, nonatomic) UILabel *stakeValueLabel;
@property (strong, nonatomic) UILabel *returnTitleLabel;
@property (strong, nonatomic) UILabel *returnValueLabel;
@property (strong, nonatomic) UILabel *profitTitleLabel;
@property (strong, nonatomic) UILabel *profitValueLabel;
@property (nonatomic, weak) ChampionshipsHeaderView *championshipsHeaderView;

@property (assign, nonatomic, getter = isTitleHidden) BOOL titleHidden;

- (void)setTitleHidden:(BOOL)titleHidden animated:(BOOL)animated;
- (CGFloat)defaultValueFontSize;

@end
