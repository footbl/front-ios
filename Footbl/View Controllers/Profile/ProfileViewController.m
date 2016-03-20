//
//  ProfileViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <SVPullToRefresh/SVPullToRefresh.h>
#import "AnonymousViewController.h"
#import "FavoritesViewController.h"
#import "FootblTabBarController.h"
#import "LoadingHelper.h"
#import "FTBMatch+Sharing.h"
#import "MatchTableViewCell+Setup.h"
#import "NSNumber+Formatter.h"
#import "ProfileChampionshipTableViewCell.h"
#import "ProfileBetsViewController.h"
#import "ProfileTableViewCell.h"
#import "ProfileViewController.h"
#import "SettingsViewController.h"
#import "TransfersHelper.h"
#import "TransfersViewController.h"
#import "WalletGraphTableViewCell.h"
#import "WalletHighestTableViewCell.h"
#import "WalletTableViewCell.h"

#import "FTBClient.h"
#import "FTBUser.h"
#import "FTBBet.h"

@interface ProfileViewController ()

@property (strong, nonatomic) AnonymousViewController *anonymousViewController;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *bets;
@property (assign, nonatomic) NSUInteger nextPage;

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
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title image:[UIImage imageNamed:@"tabbar_btn_profile_inactive"] selectedImage:[UIImage imageNamed:@"tabbar_btn_profile_active"]];
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
    favoritesViewController.shouldShowFeatured = self.user.isMe;
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

- (void)reloadContent {
    if (![[FTBClient client] isAuthenticated]) {
        self.user = nil;
        self.bets = [[NSMutableArray alloc] init];
        [self.tableView reloadData];
        return;
    }
    
    if (!self.user.isMe) {
		__weak typeof(self) this = self;
		[[FTBClient client] betsForUser:self.user match:nil page:0 success:^(id object) {
			this.bets = object;
			[this.tableView reloadData];
		} failure:nil];
    }
}

- (void)reloadData {
    [super reloadData];
    
    if (![[FTBClient client] isAuthenticated]) {
        return;
    }
    
    if (!self.user.isMe && self.bets.count == 0 && !self.refreshControl.isRefreshing) {
        [self.refreshControl beginRefreshing];
    }
    
    [self reloadContent];
    
    void(^failure)(NSError *error) = ^(NSError *error) {
        [self reloadContent];
        [self.refreshControl endRefreshing];
        [[ErrorHandler sharedInstance] displayError:error];
    };
	
	__weak typeof(self) weakSelf = self;
	[[FTBClient client] user:self.user.identifier success:^(FTBUser *user) {
		[weakSelf reloadContent];
        [weakSelf.refreshControl endRefreshing];
	} failure:failure];
}

- (void)setupInfiniteScrolling {
    if (self.tableView.infiniteScrollingView) {
        return;
    }
	
	__weak typeof(self) this = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [super reloadData];
		
		[[FTBClient client] betsForUser:this.user match:nil page:0 success:^(NSArray *bets) {
			[this.tableView.infiniteScrollingView stopAnimating];
			if (bets.count == FT_API_PAGE_LIMIT) {
				this.tableView.showsInfiniteScrolling = YES;
			} else {
				this.nextPage++;
				this.tableView.showsInfiniteScrolling = NO;
			}
		} failure:^(NSError *error) {
			[this.tableView.infiniteScrollingView stopAnimating];
			[[ErrorHandler sharedInstance] displayError:error];
		}];
    }];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0: {
                    ProfileTableViewCell *profileCell = (ProfileTableViewCell *)cell;
                    profileCell.nameLabel.text = self.user.name;
                    profileCell.usernameLabel.text = self.user.username;
                    profileCell.verified = self.user.isVerified;
                    if (self.user.isMe) {
                        profileCell.starImageView.highlightedImage = nil;
                    }
                    profileCell.aboutText = self.user.about;

                    if (self.user.numberOfFans.integerValue >= MAX_FOLLOWERS_COUNT) {
                        profileCell.followersLabel.text = [self.user.numberOfFans.shortStringValue stringByAppendingString:@"+"];
                    } else if (self.user.numberOfFans.integerValue > 0) {
                        profileCell.followersLabel.text = self.user.numberOfFans.shortStringValue;
                    } else {
                        profileCell.followersLabel.text = @"";
                    }
                    [profileCell.profileImageView sd_setImageWithURL:self.user.pictureURL placeholderImage:profileCell.placeholderImage];
                    
                    NSDateFormatter *formatter = [NSDateFormatter new];
                    formatter.dateFormat = NSLocalizedString(@"'Since' MMMM YYYY", @"Since {month format} {year format}");
                    profileCell.dateLabel.text = [formatter stringFromDate:self.user.createdAt];
					
					FTBUser *user = [FTBUser currentUser];
                    if (!self.user.isMe && [self.user isFanOfUser:user]) {
                        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                    } else {
                        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                    }
                    break;
                }
                case 1: {
                    WalletTableViewCell *walletCell = (WalletTableViewCell *)cell;
                    walletCell.valueText = self.user.totalWallet.walletStringValue;
                    walletCell.arrowImageView.hidden = YES;
                    walletCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                case 2: {
                    WalletHighestTableViewCell *walletCell = (WalletHighestTableViewCell *)cell;
                    if (self.user) {
                        [walletCell setHighestValue:@(self.user.highestWallet.integerValue) withDate:self.user.highestWalletDate];
                    } else {
                        [walletCell setHighestValue:@0 withDate:[NSDate date]];
                    }
                    break;
                }
                case 3: {
                    WalletGraphTableViewCell *walletCell = (WalletGraphTableViewCell *)cell;
                    walletCell.dataSource = self.user.history;
                    walletCell.roundsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Wallet evolution", @""), walletCell.dataSource];
                    break;
                }
                default:
                    break;
            }
            break;
        case 1: {
            switch (indexPath.row) {
                case 1: {
                    cell.textLabel.text = NSLocalizedString(@"View betting history", @"");
                    [self configureCellAppearance:cell atIndexPath:indexPath];
                    break;
                }
                default: {
                    ProfileChampionshipTableViewCell *championshipCell = (ProfileChampionshipTableViewCell *)cell;
                    [championshipCell.championshipImageView setImage:[UIImage imageNamed:@"world_icon"]];
                    championshipCell.nameLabel.text = NSLocalizedString(@"World", @"");
                    if (self.user.ranking.integerValue > 0) {
                        championshipCell.rankingLabel.text = self.user.ranking.rankingStringValue;
                    } else {
                        championshipCell.rankingLabel.text = @"";
                    }
                    
                    if (FBTweakValue(@"UX", @"Profile", @"Rank Progress", YES) && self.user.ranking && self.user.previousRanking) {
                        championshipCell.rankingProgress = @(self.user.previousRanking.integerValue - self.user.ranking.integerValue);
                    } else {
                        championshipCell.rankingProgress = @(0);
                    }
                    break;
                }
            }
            break;
        }
        case 2: {
            [self configureCellAppearance:cell atIndexPath:indexPath];
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = NSLocalizedString(@"Settings", @"");
                    break;
                default:
                    break;
            }
        }
        default:
            break;
    }
}

- (void)configureCellAppearance:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:15];
    cell.textLabel.textColor = [UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:1.00];
    
    NSInteger separatorTag = 1251123;
    if (![cell.contentView viewWithTag:separatorTag]) {
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"goto"]];
        arrowImageView.center = CGPointMake(CGRectGetWidth(self.tableView.frame) - 20, 25);
        arrowImageView.tag = separatorTag;
        [cell.contentView addSubview:arrowImageView];
        
        if (indexPath.row == 0 && indexPath.section == 2) {
            UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 0.5)];
            separatorView.backgroundColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.83 alpha:1];
            separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [cell.contentView addSubview:separatorView];
        }

        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, CGRectGetWidth(self.tableView.frame), 0.5)];
        separatorView.backgroundColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.83 alpha:1];
        separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:separatorView];
    }
}

#pragma mark - Delegates & Data sources

#pragma mark - UITableView data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 10)];
        view.backgroundColor = [UIColor clearColor];
        return view;
    } else if (section == 2 && self.bets.count > 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 7)];
        view.backgroundColor = [UIColor clearColor];
        return view;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 10;
    } else if (section == 2) {
        return 10;
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 3 + ([self.user.history count] >= MINIMUM_HISTORY_COUNT ? 1 : 0);
        case 1:
            return 2;
        case 2:
            return 1;
        default:
            return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"Cell";
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    identifier = @"ProfileCell";
                    break;
                case 1:
                    identifier = @"WalletCell";
                    break;
                case 2:
                    identifier = @"WalletHighestCell";
                    break;
                case 3:
                    identifier = @"WalletGraphCell";
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 1:
                    identifier = @"Cell";
                    break;
                default:
                    identifier = @"ChampionshipCell";
                    break;
            }
            
            break;
        case 2:
            identifier = @"Cell";
            break;
        default:
            break;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    return 93;
                case 1:
                    return 81;
                case 2:
                    return 43;
                case 3:
                    return 164;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 1:
                    return 50;
                default:
                    return 67;
            }
        case 2:
            return 50;
        default:
            break;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 1) {
        [self betsAction:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        [self settingsAction:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        [self settingsAction:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
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
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 10)];
    [self.tableView registerClass:[ProfileTableViewCell class] forCellReuseIdentifier:@"ProfileCell"];
    [self.tableView registerClass:[WalletTableViewCell class] forCellReuseIdentifier:@"WalletCell"];
    [self.tableView registerClass:[WalletHighestTableViewCell class] forCellReuseIdentifier:@"WalletHighestCell"];
    [self.tableView registerClass:[ProfileChampionshipTableViewCell class] forCellReuseIdentifier:@"ChampionshipCell"];
    [self.tableView registerClass:[MatchTableViewCell class] forCellReuseIdentifier:@"MatchCell"];
    [self.tableView registerClass:[WalletGraphTableViewCell class] forCellReuseIdentifier:@"WalletGraphCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:self.tableView];
    
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
