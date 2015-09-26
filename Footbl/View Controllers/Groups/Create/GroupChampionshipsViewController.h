//
//  GroupChampionshipsViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/3/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateViewController.h"

@interface GroupChampionshipsViewController : TemplateViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *championships;
@property (strong, nonatomic) UITableView *tableView;
@property (copy, nonatomic) NSString *groupName;
@property (strong, nonatomic) UIImage *groupImage;

@end