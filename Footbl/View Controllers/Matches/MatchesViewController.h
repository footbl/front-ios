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
@property (nonatomic, copy) NSArray *matches;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) BetsViewController *betsViewController;
@property (nonatomic, weak) MatchesNavigationBarView *navigationBarTitleView;
@property (nonatomic, strong) FTBUser *challengedUser;

@end
