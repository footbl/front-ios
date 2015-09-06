//
//  ProfileViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateViewController.h"

@class FTBUser;

@interface ProfileViewController : TemplateViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) FTBUser *user;
@property (assign, nonatomic) BOOL shouldShowSettings;
@property (assign, nonatomic) BOOL shouldShowFavorites;

@end
