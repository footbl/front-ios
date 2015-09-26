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
#import "GroupMembershipTableViewCell.h"
#import "GroupRankingViewController.h"
#import "LoadingHelper.h"
#import "NSNumber+Formatter.h"
#import "ProfileViewController.h"

#import "FTBClient.h"
#import "FTBGroup.h"
#import "FTBUser.h"

@interface GroupRankingViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSNumber *nextPage;
@property (assign, nonatomic) BOOL isLoading;

@end

#pragma mark GroupRankingViewController

@implementation GroupRankingViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (void)setContext:(GroupDetailContext)context {
    if (_context == context) {
        return;
    }
    
    _context = context;
    
    if (!self.group.isDefault) {
        [self reloadData];
    }
}

#pragma mark - Instance Methods

- (NSTimeInterval)updateInterval {
    return UPDATE_INTERVAL_NEVER;
}

- (void)reloadData {
    [super reloadData];
	
    if (self.context == GroupDetailContextRanking) {
        if (self.isLoading) {
            return;
        }
        
        self.isLoading = YES;
        
        if (self.group.members.count == 0) {
            [[LoadingHelper sharedInstance] showHud];
        }
		
        if (self.group.isWorld) {
		} else if (self.group.isFriends) {
		} else {
            [[FTBClient client] usersWithEmails:nil facebookIds:nil usernames:nil name:nil page:0 success:^(id object) {
                [self.refreshControl endRefreshing];
                [[LoadingHelper sharedInstance] hideHud];
                self.isLoading = NO;
            } failure:^(NSError *error) {
                [self.refreshControl endRefreshing];
                [[LoadingHelper sharedInstance] hideHud];
                [[ErrorHandler sharedInstance] displayError:error];
                self.isLoading = NO;
            }];
        }
    }
}

- (void)setupInfiniteScrolling {
    if (self.tableView.infiniteScrollingView || !self.group.isWorld) {
        return;
    }
    
    __weak typeof(self.tableView)weakTableView = self.tableView;
    [weakTableView addInfiniteScrollingWithActionHandler:^{
        [super reloadData];
        
        if (self.group.members.count == 0) {
            [[LoadingHelper sharedInstance] showHud];
        }
		
		[[FTBClient client] usersWithEmails:nil facebookIds:nil usernames:nil name:nil page:self.nextPage.integerValue success:^(id object) {
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
    FTBUser *user = self.group.members[indexPath.row];
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
    
    if (user.totalWallet) {
        cell.walletLabel.text = user.totalWallet.shortStringValue;
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
	return self.group.members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupMembershipTableViewCell *cell = (GroupMembershipTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FTBUser *member = self.group.members[indexPath.row];
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
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
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
