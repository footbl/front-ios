//
//  ProfileViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <SVPullToRefresh/SVPullToRefresh.h>

#import "ProfileViewController.h"
#import "AnonymousViewController.h"
#import "FavoritesViewController.h"
#import "FootblTabBarController.h"
#import "FTBBet.h"
#import "FTBClient.h"
#import "FTBMatch+Sharing.h"
#import "FTBUser.h"
#import "LoadingHelper.h"
#import "MatchTableViewCell+Setup.h"
#import "NSNumber+Formatter.h"
#import "ProfileBetsViewController.h"
#import "ProfileChallengeTableViewCell.h"
#import "ProfileChampionshipTableViewCell.h"
#import "ProfileTableViewCell.h"
#import "SettingsViewController.h"
#import "TableViewDataSource.h"
#import "TableViewRow.h"
#import "TableViewSection.h"
#import "TransfersHelper.h"
#import "TransfersViewController.h"
#import "WalletGraphTableViewCell.h"
#import "WalletHighestTableViewCell.h"
#import "WalletTableViewCell.h"
#import "BetsViewController.h"
#import "TrophiesTableViewCell.h"
#import "TrophyRoomViewController.h"
#import "ExperienceTableViewCell.h"
#import "LineView.h"

@interface ProfileViewController ()

@property (nonatomic, strong) AnonymousViewController *anonymousViewController;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, assign) NSUInteger nextPage;
@property (nonatomic, strong) TableViewDataSource *dataSource;

@end

#pragma mark ProfileViewController

@implementation ProfileViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (FTBUser *)user {
    if (!_user) {
        _user = [FTBUser currentUser];
    }
    return _user;
}

#pragma mark - Instance Methods

- (id)init {
	self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Profile", @"");
        
        UIImage *image = [UIImage imageNamed:@"tabbar-profile"];
        UIImage *selectedImage = [UIImage imageNamed:@"tabbar-profile-selected"];
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title image:image selectedImage:selectedImage];
    }
    return self;
}

- (IBAction)betsAction:(id)sender {
    ProfileBetsViewController *betsViewController = [ProfileBetsViewController new];
    betsViewController.user = self.user;
    [self.navigationController pushViewController:betsViewController animated:YES];
}

- (IBAction)favoritesAction:(id)sender {
    FavoritesViewController *favoritesViewController = [FavoritesViewController new];
    favoritesViewController.user = self.user;
    [self.navigationController pushViewController:favoritesViewController animated:YES];
}

- (IBAction)settingsAction:(id)sender {
    [self.navigationController pushViewController:[SettingsViewController new] animated:YES];
}

- (IBAction)transfersAction:(id)sender {
    [self.navigationController pushViewController:[TransfersViewController new] animated:YES];
}

- (NSTimeInterval)updateInterval {
    return UPDATE_INTERVAL_NEVER;
}

- (void)reloadData {
    [super reloadData];
    
    if (![[FTBClient client] isAuthenticated]) {
        self.user = nil;
        [self.tableView reloadData];
        return;
    }
    
    if (!self.user.isMe && !self.refreshControl.isRefreshing) {
        [self.refreshControl beginRefreshing];
    }
	
	__weak typeof(self) weakSelf = self;
	[[FTBClient client] user:self.user.identifier success:^(FTBUser *user) {
        weakSelf.user = user;
        [weakSelf reloadContent];
		[weakSelf.tableView reloadData];
        [weakSelf.refreshControl endRefreshing];
	} failure:^(NSError *error) {
        [weakSelf.tableView reloadData];
        [weakSelf.refreshControl endRefreshing];
        [[ErrorHandler sharedInstance] displayError:error];
    }];
}

- (void)reloadContent {
    __weak typeof(self) weakSelf = self;
    
    self.dataSource = [[TableViewDataSource alloc] init];

    TableViewSection *profileSection = [[TableViewSection alloc] init];
    [self.dataSource addSection:profileSection];

    TableViewRow *profileRow = [[TableViewRow alloc] initWithClass:[ProfileTableViewCell class]];
    profileRow.setup = ^(ProfileTableViewCell *cell, NSIndexPath *indexPath) {
        cell.nameLabel.text = weakSelf.user.name;
        cell.usernameLabel.text = weakSelf.user.username;
        cell.verified = weakSelf.user.isVerified;
        if (weakSelf.user.isMe) {
            cell.starImageView.highlightedImage = nil;
        }
        cell.aboutText = weakSelf.user.about;
        
        if (weakSelf.followers.count >= MAX_FOLLOWERS_COUNT) {
            cell.followersLabel.text = [NSString stringWithFormat:@"%@+", @(weakSelf.followers.count).shortStringValue];
        } else if (weakSelf.followers.count > 0) {
            cell.followersLabel.text = @(weakSelf.followers.count).shortStringValue;
        } else {
            cell.followersLabel.text = @"";
        }
        [cell.profileImageView sd_setImageWithURL:weakSelf.user.pictureURL placeholderImage:cell.placeholderImage];
        
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = NSLocalizedString(@"'Since' MMMM YYYY", @"Since {month format} {year format}");
        cell.dateLabel.text = [formatter stringFromDate:weakSelf.user.createdAt];
        
        FTBUser *me = [FTBUser currentUser];
        if (!weakSelf.user.isMe && [weakSelf.followers containsObject:me]) {
            [weakSelf.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        } else {
            [weakSelf.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    };
    profileRow.height = 93;
    [profileSection addRow:profileRow];

    TableViewSection *gameSection = [[TableViewSection alloc] init];
    [self.dataSource addSection:gameSection];

    TableViewRow *experienceRow = [[TableViewRow alloc] initWithClass:[ExperienceTableViewCell class]];
    experienceRow.setup = ^(ExperienceTableViewCell *cell, NSIndexPath *indexPath) {
        cell.progressView.progress = 0.2;
    };
    experienceRow.height = 44;
    [gameSection addRow:experienceRow];

    TableViewRow *trophiesRow = [[TableViewRow alloc] initWithClass:[TrophiesTableViewCell class]];
    trophiesRow.selection = ^(NSIndexPath *indexPath) {
        TrophyRoomViewController *viewController = [TrophyRoomViewController instantiateFromStoryboard];
        [weakSelf.navigationController pushViewController:viewController animated:YES];
    };
    trophiesRow.height = 67;
    [gameSection addRow:trophiesRow];

    TableViewSection *historySection = [[TableViewSection alloc] init];
    historySection.headerViewHeight = 10;
    [self.dataSource addSection:historySection];
    
    TableViewRow *walletRow = [[TableViewRow alloc] initWithClass:[WalletTableViewCell class]];
    walletRow.setup = ^(WalletTableViewCell *cell, NSIndexPath *indexPath) {
        cell.valueText = weakSelf.user.wallet.walletStringValue;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    };
    walletRow.height = 67;
    [historySection addRow:walletRow];
    
    TableViewRow *highestWalletRow = [[TableViewRow alloc] initWithClass:[WalletHighestTableViewCell class]];
    highestWalletRow.setup = ^(WalletHighestTableViewCell *cell, NSIndexPath *indexPath) {
        if (weakSelf.user) {
            [cell setHighestValue:weakSelf.user.highestWallet withDate:weakSelf.user.highestWalletDate];
        } else {
            [cell setHighestValue:@0 withDate:[NSDate date]];
        }
    };
    highestWalletRow.height = 43;
    [historySection addRow:highestWalletRow];
    
    if (self.user.history.count >= MINIMUM_HISTORY_COUNT) {
        TableViewRow *graphRow = [[TableViewRow alloc] initWithClass:[WalletGraphTableViewCell class]];
        graphRow.setup = ^(WalletGraphTableViewCell *cell, NSIndexPath *indexPath) {
            cell.dataSource = weakSelf.user.history;
            cell.roundsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Wallet evolution", @""), cell.dataSource];
        };
        graphRow.height = 164;
        [historySection addRow:graphRow];
    }
    
    if (!self.user.isMe) {
        TableViewSection *challengeSection = [[TableViewSection alloc] init];
        challengeSection.headerViewHeight = 10;
        [self.dataSource addSection:challengeSection];
        
        TableViewRow *challengeRow = [[TableViewRow alloc] initWithClass:[ProfileChallengeTableViewCell class]];
        challengeRow.selection = ^(NSIndexPath *indexPath) {
            BetsViewController *viewController = [[BetsViewController alloc] init];
            viewController.challengedUser = weakSelf.user;
            [weakSelf.navigationController pushViewController:viewController animated:YES];
        };
        challengeRow.height = 50;
        [challengeSection addRow:challengeRow];
    }
    
    TableViewSection *rankingSection = [[TableViewSection alloc] init];
    rankingSection.headerViewHeight = 10;
    [self.dataSource addSection:rankingSection];
    
    TableViewRow *championshipRow = [[TableViewRow alloc] initWithClass:[ProfileChampionshipTableViewCell class]];
    championshipRow.setup = ^(ProfileChampionshipTableViewCell *cell, NSIndexPath *indexPath) {
        cell.championshipImageView.image = [UIImage imageNamed:@"world_icon"];
        cell.nameLabel.text = NSLocalizedString(@"World", @"");
        if (weakSelf.user.ranking.integerValue > 0) {
            cell.rankingLabel.text = weakSelf.user.ranking.rankingStringValue;
        } else {
            cell.rankingLabel.text = @"";
        }
        
        if (FBTweakValue(@"UX", @"Profile", @"Rank Progress", YES) && weakSelf.user.ranking && weakSelf.user.previousRanking) {
            cell.rankingProgress = @(weakSelf.user.previousRanking.integerValue - weakSelf.user.ranking.integerValue);
        } else {
            cell.rankingProgress = @0;
        }
    };
    championshipRow.height = 67;
    [rankingSection addRow:championshipRow];
    
    TableViewRow *historyRow = [[TableViewRow alloc] initWithClass:[UITableViewCell class]];
    historyRow.setup = ^(UITableViewCell *cell, NSIndexPath *indexPath) {
        cell.textLabel.text = NSLocalizedString(@"View betting history", @"");
        [weakSelf configureCellAppearance:cell atIndexPath:indexPath];
    };
    historyRow.selection = ^(NSIndexPath *indexPath) {
        [weakSelf betsAction:nil];
    };
    historyRow.height = 50;
    [rankingSection addRow:historyRow];
    
    if (self.user.isMe) {
        TableViewSection *settingsSection = [[TableViewSection alloc] init];
        settingsSection.headerViewHeight = 10;
        [self.dataSource addSection:settingsSection];
        
        TableViewRow *settingsRow = [[TableViewRow alloc] initWithClass:[UITableViewCell class]];
        settingsRow.setup = ^(UITableViewCell *cell, NSIndexPath *indexPath) {
            cell.textLabel.text = NSLocalizedString(@"Settings", @"");
            [weakSelf configureCellAppearance:cell atIndexPath:indexPath];
        };
        settingsRow.selection = ^(NSIndexPath *indexPath) {
            [weakSelf settingsAction:nil];
        };
        settingsRow.height = 50;
        [settingsSection addRow:settingsRow];
    }

    for (NSUInteger sectionIndex = 0; sectionIndex < self.dataSource.numberOfSections; sectionIndex++) {
        TableViewSection *section = [self.dataSource sectionAtIndex:sectionIndex];
        for (NSUInteger rowIndex = 0; rowIndex < section.numberOfRows; rowIndex++) {
            TableViewRow *row = [section rowAtIndex:rowIndex];
            [self.tableView registerClass:row.resuseClass forCellReuseIdentifier:row.resuseIdentifier];
        }
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    TableViewSection *section = [self.dataSource sectionAtIndex:indexPath.section];
    TableViewRow *row = [section rowAtIndex:indexPath.row];
    if (row.setup) {
        row.setup(cell, indexPath);
    }
}

- (void)configureCellAppearance:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:15];
    cell.textLabel.textColor = [UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:1.00];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark - Delegates & Data sources

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)aSection {
    TableViewSection *section = [self.dataSource sectionAtIndex:aSection];
    return section.numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewSection *section = [self.dataSource sectionAtIndex:indexPath.section];
    TableViewRow *row = [section rowAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:row.resuseIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewSection *section = [self.dataSource sectionAtIndex:indexPath.section];
    TableViewRow *row = [section rowAtIndex:indexPath.row];
    return row.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewSection *section = [self.dataSource sectionAtIndex:indexPath.section];
    TableViewRow *row = [section rowAtIndex:indexPath.row];
    if (row.selection) {
        row.selection(indexPath);
    }
    
    if (self.user.isMe) {
        return;
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) {
		[[FTBClient client] followUser:self.user success:nil failure:^(NSError *error) {
			[[ErrorHandler sharedInstance] displayError:error];
		}];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.user.isMe) {
        return;
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) {
		[[FTBClient client] unfollowUser:self.user.identifier success:nil failure:^(NSError *error) {
			[[ErrorHandler sharedInstance] displayError:error];
		}];
    }
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"message_inbox"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(transfersAction:)];
    self.view.backgroundColor = [UIColor ftb_viewMatchBackgroundColor];
    
    if (self.user.isMe) {
		[[FTBClient client] userFollowing:self.user success:nil failure:nil];
    }
    
    self.anonymousViewController = [AnonymousViewController new];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    tableViewController.refreshControl = self.refreshControl;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kFTNotificationAuthenticationChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        self.user = nil;
        [self reloadData];
        
        if ([[FTBClient client] isAnonymous]) {
            [self addChildViewController:self.anonymousViewController];
            [self.view addSubview:self.anonymousViewController.view];
            self.navigationItem.rightBarButtonItem.enabled = NO;
            self.navigationItem.leftBarButtonItem.enabled = NO;
        } else {
            [self.anonymousViewController.view removeFromSuperview];
            [self.anonymousViewController removeFromParentViewController];
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.navigationItem.leftBarButtonItem.enabled = YES;
        }
    }];
    
    self.tableView = tableViewController.tableView;
    self.tableView.frame = self.view.bounds;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.layoutMargins = UIEdgeInsetsZero;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 10)];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), FLT_MIN)];
    self.tableView.sectionHeaderHeight = 10;
    self.tableView.sectionFooterHeight = 0;
    [self.view addSubview:self.tableView];
    
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    [TransfersHelper fetchCountWithBlock:^(NSUInteger count) {
        if (count == 0) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"message_inbox_empty"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(transfersAction:)];
        } else {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"message_inbox"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(transfersAction:)];
        }
    }];
    
    for (UIView *view in self.tabBarController.tabBar.subviews) {
        if ([view isKindOfClass:[UIImageView class]] && CGRectGetHeight(view.frame) < 2) {
            view.backgroundColor = [UIColor ftb_tabBarSeparatorColor];
        }
    }
    
    if ([[FTBClient client] isAnonymous]) {
        [self addChildViewController:self.anonymousViewController];
        [self.view addSubview:self.anonymousViewController.view];
        for (UIBarButtonItem *button in self.navigationItem.rightBarButtonItems) {
            button.enabled = NO;
        }
        self.navigationItem.leftBarButtonItem.enabled = NO;
    } else {
        [self.anonymousViewController.view removeFromSuperview];
        [self.anonymousViewController removeFromParentViewController];
        for (UIBarButtonItem *button in self.navigationItem.rightBarButtonItems) {
            button.enabled = YES;
        }
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
}

@end
