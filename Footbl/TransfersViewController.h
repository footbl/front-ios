//
//  TransfersViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 7/29/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TemplateViewController.h"

@interface TransfersViewController : TemplateViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UILabel *walletLabel;
@property (strong, nonatomic) UILabel *stakeLabel;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UITableView *tableView;

@end
