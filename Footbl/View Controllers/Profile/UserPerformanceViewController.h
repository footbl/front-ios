//
//  UserPerformanceViewController.h
//  Footbl
//
//  Created by Leonardo Formaggio on 9/6/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "TemplateViewController.h"

@interface UserPerformanceViewController : TemplateViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIColor *evenColor;
@property (nonatomic, strong) UIColor *oddColor;

@end
