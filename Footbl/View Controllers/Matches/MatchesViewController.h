//
//  MatchesViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 3/27/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateViewController.h"

@class FTBUser;
@class FTBChampionship;
@class MatchesNavigationBarView;
@class BetsViewController;

@interface MatchesViewController : TemplateViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) FTBChampionship *championship;
@property (nonatomic, strong) NSMutableArray *matches;
@property (nonatomic, strong) FTBUser *challengedUser;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) BetsViewController *betsViewController;
@property (nonatomic, weak) MatchesNavigationBarView *navigationBarTitleView;

@end
