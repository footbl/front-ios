//
//  GroupAddMembersViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/3/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TemplateViewController.h"

@class Group;

@interface GroupAddMembersViewController : TemplateViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (copy, nonatomic) NSString *groupName;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UIView *segmentedControlBackgroundView;
@property (strong, nonatomic) UIView *separatorView;
@property (strong, nonatomic) UIImage *groupImage;
@property (strong, nonatomic) Group *group;

@end
