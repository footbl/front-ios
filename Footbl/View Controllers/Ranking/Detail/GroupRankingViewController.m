//
//  GroupRankingViewController.m
//  Footbl
//
//  Created by Fernando Saragoca on 11/21/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <SDWebImage/UIButton+WebCache.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SPHipster/SPHipster.h>
#import <SVPullToRefresh/SVPullToRefresh.h>

#import "GroupRankingViewController.h"
#import "FriendsHelper.h"
#import "FTBClient.h"
#import "FTBGroup.h"
#import "FTBUser.h"
#import "GroupMembershipTableViewCell.h"
#import "LoadingHelper.h"
#import "NSNumber+Formatter.h"
#import "ProfileViewController.h"

@interface GroupRankingViewController ()

@property (nonatomic, copy) NSMutableArray<FTBUser *> *members;
@property (nonatomic, copy) NSNumber *nextPage;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, assign) BOOL isLoading;

@end

#pragma mark GroupRankingViewController

@implementation GroupRankingViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (NSTimeInterval)updateInterval {
    return UPDATE_INTERVAL_NEVER;
}

- (void)reloadData {
    [super reloadData];
	
    if (self.isLoading) {
        return;
    }
    
    self.isLoading = YES;
    
    if (self.members.count == 0) {
        [[LoadingHelper sharedInstance] showHud];
    }
    
    
    FTBBlockObject success = ^(id object) {
        self.members = [[NSMutableArray alloc] initWithArray:object];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        [[LoadingHelper sharedInstance] hideHud];
        self.isLoading = NO;
    };
    
    FTBBlockError failure = ^(NSError *error) {
        [self.refreshControl endRefreshing];
        [[LoadingHelper sharedInstance] hideHud];
        [[ErrorHandler sharedInstance] displayError:error];
        self.isLoading = NO;
    };
    
    if (self.group.type == FTBGroupTypeWorld) {
        [[FTBClient client] users:0 success:success failure:failure];
    } else if (self.group.type == FTBGroupTypeCountry) {
        FTBUser *user = [FTBUser currentUser];
        [[FTBClient client] usersWithCountry:user.ISOCountryCode page:0 success:success failure:failure];
    } else {
        [[FriendsHelper sharedInstance] getFriendsWithCompletionBlock:^(NSArray *friends, NSError *error) {
            if (friends && !error) {
                success(friends);
            } else {
                failure(error);
            }
        }];
    }
}

- (void)setupInfiniteScrolling {
    if (self.tableView.infiniteScrollingView) {
        return;
    }
    
    __weak typeof(self.tableView)weakTableView = self.tableView;
    [weakTableView addInfiniteScrollingWithActionHandler:^{
        [super reloadData];
        
        if (self.members.count == 0) {
            [[LoadingHelper sharedInstance] showHud];
        }
		
		[[FTBClient client] usersWithEmails:nil facebookIds:nil usernames:nil names:nil page:self.nextPage.integerValue success:^(id object) {
            [weakTableView.infiniteScrollingView stopAnimating];
			self.tableView.showsInfiniteScrolling = NO;
            [[LoadingHelper sharedInstance] hideHud];
            self.nextPage = @(self.nextPage.integerValue + 1);
        } failure:^(NSError *error) {
            [weakTableView.infiniteScrollingView stopAnimating];
            [[LoadingHelper sharedInstance] hideHud];
            [[ErrorHandler sharedInstance] displayError:error];
        }];
    }];
}

- (void)configureCell:(GroupMembershipTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    FTBUser *user = self.members[indexPath.row];
    if (user.ranking) {
        cell.rankingLabel.text = user.ranking.rankingStringValue;
    } else {
        cell.rankingLabel.text = @(indexPath.row + 1).rankingStringValue;
    }
    
    cell.usernameLabel.text = user.username;
    cell.nameLabel.text = user.name;
    
    if (user.previousRanking && user.ranking) {
        cell.rankingProgress = @(user.previousRanking.integerValue - user.ranking.integerValue);
    } else {
        cell.rankingProgress = @(0);
    }
    
    if (user.wallet) {
        cell.walletLabel.text = user.wallet.shortStringValue;
    } else {
        cell.walletLabel.text = @"";
    }
    
    [cell.profileImageView sd_setImageWithURL:user.pictureURL placeholderImage:cell.placeholderImage];
    
    if (FBTweakValue(@"UI", @"Group", @"Medals", FT_ENABLE_MEDALS)) {
        switch (indexPath.row) {
            case 0:
                cell.medalImageView.image = [UIImage imageNamed:@"groups_medal_gold"];
                break;
            case 1:
                cell.medalImageView.image = [UIImage imageNamed:@"groups_medal_silver"];
                break;
            case 2:
                cell.medalImageView.image = [UIImage imageNamed:@"groups_medal_bronze"];
                break;
            default:
                cell.medalImageView.image = nil;
                break;
        }
    }
}

#pragma mark - Protocols

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupMembershipTableViewCell *cell = (GroupMembershipTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FTBUser *member = self.members[indexPath.row];
    ProfileViewController *profileViewController = [ProfileViewController new];
    profileViewController.user = member;
    [self.navigationController pushViewController:profileViewController animated:YES];
}

#pragma mark - NSFetchedResultsController delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.group.name;
    self.view.backgroundColor = [UIColor ftb_viewMatchBackgroundColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    tableViewController.refreshControl = self.refreshControl;
    
    self.tableView = tableViewController.tableView;
    self.tableView.frame = self.view.bounds;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = 75;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.tableView registerClass:[GroupMembershipTableViewCell class] forCellReuseIdentifier:@"GroupCell"];
    [self.view addSubview:self.tableView];
    
    [self reloadData];
    
    if (self.tableView.indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
       
    if (self.tableView.indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
