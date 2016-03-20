//
//  GroupAroundMeViewController.m
//  Footbl
//
//  Created by Cesar Barscevicius on 11/24/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "GroupAroundMeViewController.h"

#import "FTBClient.h"
#import "FTBGroup.h"
#import "FTBUser.h"

@interface GroupAroundMeViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSDate *lastUpdateAt;

@end

#pragma mark GroupRankingViewController

@implementation GroupAroundMeViewController

- (void)setContext:(GroupDetailContext)context {
    [super setContext:context];
    
    if (context == GroupDetailContextAroundMe) {
		FTBUser *user = [FTBUser currentUser];
		NSUInteger row = [self.group.members indexOfObject:user];
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}

#pragma mark - Instance Methods

- (void)reloadData {
    [super reloadData];

#warning We must implement an 'around me' API
//    [self.group getLocalRankingMembersWithSuccess:^(id response) {
//        [self.refreshControl endRefreshing];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [self.refreshControl endRefreshing];
//        [[ErrorHandler sharedInstance] displayError:error];
//    }];
}

#pragma mark - Delegates & Data sources

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
