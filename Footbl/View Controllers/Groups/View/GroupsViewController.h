//
//  GroupsViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TemplateViewController.h"

@interface GroupsViewController : TemplateViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end