//
//  GroupsViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateViewController.h"

@interface GroupsViewController : TemplateViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray *groups;
@property (nonatomic, strong) UITableView *tableView;

@end
