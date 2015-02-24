//
//  GroupRankingViewController.m
//  Footbl
//
//  Created by Fernando Saragoca on 11/21/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIButton+WebCache.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVPullToRefresh/SVPullToRefresh.h>
#import "Group.h"
#import "GroupMembershipTableViewCell.h"
#import "GroupRankingViewController.h"
#import "LoadingHelper.h"
#import "Membership.h"
#import "NSNumber+Formatter.h"
#import "ProfileViewController.h"
#import "User.h"

@interface GroupRankingViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSNumber *nextPage;
@property (assign, nonatomic) BOOL isLoading;

@end

#pragma mark GroupRankingViewController

@implementation GroupRankingViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController && self.group) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Membership"];
        if (self.group.isDefaultValue) {
            fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"ranking" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"user.funds" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"user.name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"group = %@ AND user != nil AND hasRanking = %@ AND isLocalRanking = %@", self.group, @YES, @NO];
        } else {
            fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"hasRanking" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"ranking" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"user.funds" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"user.name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"group = %@ AND user != nil", self.group];
        }
        
        fetchRequest.includesSubentities = YES;
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[FTCoreDataStore mainQueueContext] sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![_fetchedResultsController performFetch:&error]) {
            SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return _fetchedResultsController;
}

- (void)setContext:(GroupDetailContext)context {
    if (_context == context) {
        return;
    }
    
    _context = context;
    
    if (!self.group.isDefaultValue) {
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
        
        if (self.fetchedResultsController.fetchedObjects.count == 0) {
            [[LoadingHelper sharedInstance] showHud];
        }

        if (self.group.isDefaultValue) {
            [self.group.editableObject getWorldMembersWithPage:0 success:^(NSNumber *nextPage) {
                [self setupInfiniteScrolling];
                self.tableView.showsInfiniteScrolling = (nextPage != nil);
                self.nextPage = nextPage;
                [self.refreshControl endRefreshing];
                [[LoadingHelper sharedInstance] hideHud];
                self.isLoading = NO;
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self.refreshControl endRefreshing];
                [[LoadingHelper sharedInstance] hideHud];
                [[ErrorHandler sharedInstance] displayError:error];
                self.isLoading = NO;
            }];
        } else {
            [self.group.editableObject getMembersWithSuccess:^(NSArray *members) {
                [self.refreshControl endRefreshing];
                [[LoadingHelper sharedInstance] hideHud];
                self.isLoading = NO;
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self.refreshControl endRefreshing];
                [[LoadingHelper sharedInstance] hideHud];
                [[ErrorHandler sharedInstance] displayError:error];
                self.isLoading = NO;
            }];
        }
    }
}

- (void)setupInfiniteScrolling {
    if (self.tableView.infiniteScrollingView || !self.group.isDefaultValue) {
        return;
    }
    
    __weak typeof(self.tableView)weakTableView = self.tableView;
    [weakTableView addInfiniteScrollingWithActionHandler:^{
        [super reloadData];
        
        if (self.fetchedResultsController.fetchedObjects.count == 0) {
            [[LoadingHelper sharedInstance] showHud];
        }
        
        [self.group.editableObject getWorldMembersWithPage:self.nextPage.integerValue success:^(NSNumber *nextPage) {
            [weakTableView.infiniteScrollingView stopAnimating];
            self.tableView.showsInfiniteScrolling = (nextPage != nil);
            [[LoadingHelper sharedInstance] hideHud];
            self.nextPage = nextPage;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [weakTableView.infiniteScrollingView stopAnimating];
            [[LoadingHelper sharedInstance] hideHud];
            [[ErrorHandler sharedInstance] displayError:error];
        }];
    }];
}

- (void)configureCell:(GroupMembershipTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Membership *membership = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (membership.ranking) {
        cell.rankingLabel.text = membership.ranking.rankingStringValue;
    } else {
        cell.rankingLabel.text = @(indexPath.row + 1).rankingStringValue;
    }
    
    cell.usernameLabel.text = membership.user.username;
    cell.nameLabel.text = membership.user.name;
    
    if (membership.previousRanking && membership.ranking) {
        cell.rankingProgress = @(membership.previousRanking.integerValue - membership.ranking.integerValue);
    } else {
        cell.rankingProgress = @(0);
    }
    
    if (membership.user.totalWallet) {
        cell.walletLabel.text = membership.user.totalWallet.shortStringValue;
    } else {
        cell.walletLabel.text = @"";
    }
    
    [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:membership.user.picture] placeholderImage:cell.placeholderImage];
    
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
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
    if (self.group.isDefaultValue) {
        return MIN([sectionInfo numberOfObjects], (self.nextPage.integerValue + 1) * FT_API_PAGE_LIMIT);
    } else {
        return [sectionInfo numberOfObjects];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupMembershipTableViewCell *cell = (GroupMembershipTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Membership *membership = [self.fetchedResultsController objectAtIndexPath:indexPath];
    ProfileViewController *profileViewController = [ProfileViewController new];
    profileViewController.user = membership.user;
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
