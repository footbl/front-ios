//
//  BetsViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 7/10/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateViewController.h"

@class FTBUser;
@class MatchesNavigationBarView;
@class ChampionshipsHeaderView;

@interface BetsViewController : TemplateViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, copy) NSArray *championships;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) MatchesNavigationBarView *navigationBarTitleView;
@property (nonatomic, strong) ChampionshipsHeaderView *championshipsHeaderView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) FTBUser *challengedUser;

- (void)reloadWallet;
- (IBAction)rechargeWalletAction:(id)sender;

@end
