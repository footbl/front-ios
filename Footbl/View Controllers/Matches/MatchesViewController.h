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
@property (nonatomic, strong) NSArray *matches;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) BetsViewController *betsViewController;
@property (nonatomic, weak) MatchesNavigationBarView *navigationBarTitleView;

@end
