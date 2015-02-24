//
//  MyLeaguesViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 8/15/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TemplateViewController.h"

@interface MyLeaguesViewController : TemplateViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
