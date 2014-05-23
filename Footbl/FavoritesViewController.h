//
//  FavoritesViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/23/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TemplateViewController.h"

@class User;

@interface FavoritesViewController : TemplateViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) User *user;
@property (assign, nonatomic) BOOL shouldShowFeatured;

@end
