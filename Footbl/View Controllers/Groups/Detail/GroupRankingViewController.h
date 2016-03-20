//
//  GroupRankingViewController.h
//  Footbl
//
//  Created by Fernando Saragoca on 11/21/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateViewController.h"
#import "GroupDetailViewController.h"

@class FTBGroup;

@interface GroupRankingViewController : TemplateViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) FTBGroup *group;
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic) GroupDetailContext context;

@end
