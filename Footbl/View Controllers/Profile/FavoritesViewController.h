//
//  FavoritesViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/23/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateViewController.h"

@class FTBUser;

@interface FavoritesViewController : TemplateViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *favorites;
@property (strong, nonatomic) FTBUser *user;

@end
