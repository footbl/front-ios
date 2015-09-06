//
//  ProfileBetsViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 7/31/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateViewController.h"
#import "MatchTableViewCell.h"

@class FTBUser;

@interface ProfileBetsViewController : TemplateViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) FTBUser *user;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *bets;
@property (assign, nonatomic) BOOL simpleSelection;
@property (copy, nonatomic) void (^itemSelectionBlock)(MatchTableViewCell *cell);

@end
