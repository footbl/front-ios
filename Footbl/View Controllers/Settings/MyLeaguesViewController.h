//
//  MyLeaguesViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 8/15/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateViewController.h"

@interface MyLeaguesViewController : TemplateViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSArray *championships;
@property (nonatomic, strong) UITableView *tableView;

@end
