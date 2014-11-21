//
//  GroupRankingViewController.h
//  Footbl
//
//  Created by Fernando Saragoca on 11/21/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TemplateViewController.h"

@class Group;

@interface GroupRankingViewController : TemplateViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
