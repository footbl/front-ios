//
//  MatchesViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 3/27/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateViewController.h"

@class FTBChampionship;
@class MatchesNavigationBarView;

@interface MatchesViewController : TemplateViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) FTBChampionship *championship;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *matches;
@property (nonatomic, strong) MatchesNavigationBarView *navigationBarTitleView;

// ???: We may remove this
// Total profit
@property (nonatomic, strong) UIView *totalProfitView;
@property (nonatomic, strong) UIView *totalProfitBoxView;
@property (nonatomic, strong) UILabel *totalProfitLabel;
@property (nonatomic, strong) UIImageView *totalProfitArrowImageView;

@end
