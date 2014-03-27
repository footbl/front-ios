//
//  TeamsViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 3/27/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "SPTemplateViewController.h"

@class Championship;

@interface TeamsViewController : SPTemplateViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) Championship *championship;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
