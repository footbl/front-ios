//
//  ProfileViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TemplateViewController.h"

@class User;

@interface ProfileViewController : TemplateViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) User *user;
@property (assign, nonatomic) BOOL shouldShowSettings;
@property (assign, nonatomic) BOOL shouldShowFavorites;

@end
