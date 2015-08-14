//
//  MatchesViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 3/27/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateViewController.h"

@class Championship;
@class MatchesNavigationBarView;

@interface MatchesViewController : TemplateViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) Championship *championship;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) MatchesNavigationBarView *navigationBarTitleView;
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) UIImageView *headerSliderBackImageView;
@property (strong, nonatomic) UIImageView *headerSliderForwardImageView;

// Total profit
@property (strong, nonatomic) UIView *totalProfitView;
@property (strong, nonatomic) UIView *totalProfitBoxView;
@property (strong, nonatomic) UILabel *totalProfitLabel;
@property (strong, nonatomic) UIImageView *totalProfitArrowImageView;

@end
