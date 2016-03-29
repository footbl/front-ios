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

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FTBUser *user;
@property (nonatomic, copy) NSArray<FTBUser *> *followers;

@end
