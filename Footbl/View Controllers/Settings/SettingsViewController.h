//
//  SettingsViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/24/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateViewController.h"

@interface SettingsViewController : TemplateViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) UITableView *tableView;

- (void)updateProfilePictureAction:(id)sender;

@end
