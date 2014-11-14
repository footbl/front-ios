//
//  ProfileViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <SVPullToRefresh/SVPullToRefresh.h>
#import "AnonymousViewController.h"
#import "Bet.h"
#import "Championship.h"
#import "FavoritesViewController.h"
#import "FTAuthenticationManager.h"
#import "FootblTabBarController.h"
#import "LoadingHelper.h"
#import "Match+Sharing.h"
#import "MatchTableViewCell+Setup.h"
#import "NSNumber+Formatter.h"
#import "ProfileChampionshipTableViewCell.h"
#import "ProfileBetsViewController.h"
#import "ProfileTableViewCell.h"
#import "ProfileViewController.h"
#import "SettingsViewController.h"
#import "TransfersViewController.h"
#import "User.h"
#import "WalletGraphTableViewCell.h"
#import "WalletHighestTableViewCell.h"
#import "WalletTableViewCell.h"

@interface ProfileViewController ()

@property (strong, nonatomic) AnonymousViewController *anonymousViewController;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSArray *bets;
@property (strong, nonatomic) NSNumber *nextPage;

@end

#pragma mark ProfileViewController

@implementation ProfileViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (User *)user {
    if (!_user) {
        _user = [User currentUser];
    }
    
    return _user;
}

- (void)setShouldShowSettings:(BOOL)shouldShowSettings {
    _shouldShowSettings = shouldShowSettings;
    
    if (self.shouldShowSettings) {
        if (FBTweakValue(@"UX", @"Profile", @"Transfers", YES)) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"message_inbox"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(transfersAction:)];
        } else {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Settings", @"") style:UIBarButtonItemStylePlain target:self action:@selector(settingsAction:)];
        }
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)setShouldShowFavorites:(BOOL)shouldShowFavorites {
    _shouldShowFavorites = shouldShowFavorites;

    self.navigationItem.leftBarButtonItem = nil;
    
    if (self.shouldShowFavorites) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Favorites", @"") style:UIBarButtonItemStylePlain target:self action:@selector(favoritesAction:)];
    }
}

- (void)setNextPage:(NSNumber *)nextPage {
    _nextPage = nextPage;
    
    [self.tableView reloadData];
}

#pragma mark - Instance Methods

- (id)init {
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
    favoritesViewController.shouldShowFeatured = self.user.isMeValue;
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
    if (![FTAuthenticationManager sharedManager].isAuthenticated) {
        self.user = nil;
        self.bets = @[];
        [self.tableView reloadData];
        return;
    }
    
    if (!self.user.isMeValue) {
        self.bets = [self.user.bets sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"match.date" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"match.rid" ascending:NO]]];
        self.bets = [self.bets subarrayWithRange:NSMakeRange(0, MIN(self.bets.count, MAX(1, self.nextPage.integerValue) * 20))];
    }

    [self.tableView reloadData];
}

- (void)reloadData {
    [super reloadData];
    
    if (![FTAuthenticationManager sharedManager].isAuthenticated) {
        return;
    }
    
    if (!self.user.isMeValue && self.bets.count == 0 && !self.refreshControl.isRefreshing) {
        [self.refreshControl beginRefreshing];
    }
    
    [self reloadContent];
    
    void(^failure)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [self reloadContent];
        [self.refreshControl endRefreshing];
        [[ErrorHandler sharedInstance] displayError:error];
    };
    
    [self.user.editableObject getWithSuccess:^(id response) {
        [self reloadContent];
        
        if (FBTweakValue(@"UX", @"Profile", @"Transfers", YES) && self.shouldShowSettings) {
            [self reloadContent];
            [self.refreshControl endRefreshing];
        } else {
            [Bet getWithObject:self.user.editableObject page:0 success:^(NSNumber *nextPage) {
                [self setupInfiniteScrolling];
                self.tableView.showsInfiniteScrolling = (nextPage != nil);
                self.nextPage = nextPage;
                [self.refreshControl endRefreshing];
                [[LoadingHelper sharedInstance] hideHud];
            } failure:failure];
        }
    } failure:failure];
}

- (void)setupInfiniteScrolling {
    if (self.tableView.infiniteScrollingView) {
        return;
    }
    
    __weak typeof(self.tableView)weakTableView = self.tableView;
    [weakTableView addInfiniteScrollingWithActionHandler:^{
        [super reloadData];
        
        [Bet getWithObject:self.user.editableObject page:self.nextPage.integerValue success:^(NSNumber *nextPage) {
            [weakTableView.infiniteScrollingView stopAnimating];
            self.nextPage = nextPage;
            if (nextPage) {
                self.nextPage = nextPage;
                self.tableView.showsInfiniteScrolling = YES;
            } else {
                self.nextPage = @(self.nextPage.integerValue + 1);
                self.tableView.showsInfiniteScrolling = NO;
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [weakTableView.infiniteScrollingView stopAnimating];
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
                    profileCell.verified = self.user.verifiedValue;
                    if (self.user.isMeValue) {
                        profileCell.starImageView.highlightedImage = nil;
                    }
                    profileCell.aboutText = self.user.about;

                    if (self.user.numberOfFansValue >= MAX_FOLLOWERS_COUNT) {
                        profileCell.followersLabel.text = [self.user.numberOfFans.shortStringValue stringByAppendingString:@"+"];
                    } else if (self.user.numberOfFansValue > 0) {
                        profileCell.followersLabel.text = self.user.numberOfFans.shortStringValue;
                    } else {
                        profileCell.followersLabel.text = @"";
                    }
                    [profileCell.profileImageView sd_setImageWithURL:[NSURL URLWithString:self.user.picture] placeholderImage:profileCell.placeholderImage];
                    
                    NSDateFormatter *formatter = [NSDateFormatter new];
                    formatter.dateFormat = NSLocalizedString(@"'Since' MMMM YYYY", @"Since {month format} {year format}");
                    profileCell.dateLabel.text = [formatter stringFromDate:self.user.createdAt];
                    
                    if (!self.user.isMeValue && [self.user isFanOfUser:[User currentUser]]) {
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
                    if (self.user.numberOfLeaguesValue <= 1) {
                        walletCell.leaguesLabel.text = NSLocalizedString(@"Betting in 1 league", @"");
                    } else {
                        walletCell.leaguesLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Betting in %i leagues", @"Betting in {number of leagues} leagues"), self.user.numberOfLeaguesValue];
                    }
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
                    cell.textLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:15];
                    cell.textLabel.textColor = [UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:1.00];
                    
                    NSInteger separatorTag = 1251123;
                    if (![cell.contentView viewWithTag:separatorTag]) {
                        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"goto"]];
                        arrowImageView.center = CGPointMake(CGRectGetWidth(self.tableView.frame) - 20, 25);
                        [cell.contentView addSubview:arrowImageView];
                        
                        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, CGRectGetWidth(self.tableView.frame), 0.5)];
                        separatorView.backgroundColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.83 alpha:1];
                        separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                        separatorView.tag = separatorTag;
                        [cell.contentView addSubview:separatorView];
                    }
                    
                    break;
                }
                default: {
                    ProfileChampionshipTableViewCell *championshipCell = (ProfileChampionshipTableViewCell *)cell;
                    [championshipCell.championshipImageView setImage:[UIImage imageNamed:@"world_icon"]];
                    championshipCell.nameLabel.text = NSLocalizedString(@"World", @"");
                    if (self.user.ranking && self.user.rankingValue > 0) {
                        championshipCell.rankingLabel.text = self.user.ranking.rankingStringValue;
                    } else {
                        championshipCell.rankingLabel.text = @"";
                    }
                    
                    if (FBTweakValue(@"UX", @"Profile", @"Rank progress", NO) && self.user.ranking && self.user.previousRanking) {
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
            if (FBTweakValue(@"UX", @"Profile", @"Transfers", YES) && self.shouldShowSettings) {
                cell.textLabel.text = NSLocalizedString(@"Settings", @"");
                cell.textLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:15];
                cell.textLabel.textColor = [UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:1.00];
                
                NSInteger separatorTag = 1251123;
                if (![cell.contentView viewWithTag:separatorTag]) {
                    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"goto"]];
                    arrowImageView.center = CGPointMake(CGRectGetWidth(self.tableView.frame) - 20, 25);
                    [cell.contentView addSubview:arrowImageView];
                    
                    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 0.5)];
                    separatorView.backgroundColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.83 alpha:1];
                    separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                    separatorView.tag = separatorTag;
                    [cell.contentView addSubview:separatorView];
                    
                    separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, CGRectGetWidth(self.tableView.frame), 0.5)];
                    separatorView.backgroundColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.83 alpha:1];
                    separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                    [cell.contentView addSubview:separatorView];
                }
                
                break;
            }
            
            Bet *bet = self.bets[indexPath.row];
            [(MatchTableViewCell *)cell setMatch:bet.match bet:bet viewController:self selectionBlock:nil];
            break;
        }
        default:
            break;
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
        if (FBTweakValue(@"UX", @"Profile", @"Transfers", YES) && self.shouldShowSettings) {
            return 10;
        } else if (self.bets.count > 0) {
            return 7;
        }
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 3 + (FBTweakValue(@"UX", @"Profile", @"Graph", YES) && [self.user.history count] >= MINIMUM_HISTORY_COUNT ? 1 : 0);
        case 1:
            return 1 + (FBTweakValue(@"UX", @"Profile", @"Transfers", YES) && self.shouldShowSettings ? 1 : 0);
        case 2:
            return FBTweakValue(@"UX", @"Profile", @"Transfers", YES) && self.shouldShowSettings ? 1 : self.bets.count;
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
            if (FBTweakValue(@"UX", @"Profile", @"Transfers", YES) && self.shouldShowSettings) {
                identifier = @"Cell";
            } else {
                identifier = @"MatchCell";
            }
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
        case 2: {
            if (FBTweakValue(@"UX", @"Profile", @"Transfers", YES) && self.shouldShowSettings) {
                return 50;
            }
            
            Match *match = [self.bets[indexPath.row] match];
            if (match.elapsed || match.finishedValue) {
                return 363;
            } else {
                return 340;
            }
        }
        default:
            break;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.shouldShowSettings) {
        if (FBTweakValue(@"UX", @"Profile", @"Transfers", YES)) {
            if (indexPath.section == 1 && indexPath.row == 1) {
                [self betsAction:nil];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            } else if (indexPath.section == 2 && indexPath.row == 0) {
                [self settingsAction:nil];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
    }
    
    if (self.user.isMeValue) {
        return;
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        [[User currentUser].editableObject starUser:self.user.editableObject success:nil failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[ErrorHandler sharedInstance] displayError:error];
        }];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.user.isMeValue) {
        return;
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        [[User currentUser].editableObject unstarUser:self.user.editableObject success:nil failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[ErrorHandler sharedInstance] displayError:error];
        }];
    }
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    
    if (self.user.isMeValue) {
        [self.user.editableObject getStarredWithSuccess:nil failure:nil];
    }
    
    self.anonymousViewController = [AnonymousViewController new];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    tableViewController.refreshControl = self.refreshControl;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self reloadContent];
        [self performSelector:@selector(reloadContent) withObject:nil afterDelay:0.5];
        [self performSelector:@selector(reloadContent) withObject:nil afterDelay:1];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kFTNotificationAuthenticationChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        self.user = nil;
        [self reloadData];
        
        if ([FTAuthenticationManager sharedManager].authenticationType == FTAuthenticationTypeAnonymous) {
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
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), FBTweakValue(@"UX", @"Profile", @"Transfers", YES) && self.shouldShowSettings ? 10 : 5)];
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

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.shouldShowSettings = self.shouldShowSettings;
    self.shouldShowFavorites = self.shouldShowFavorites;
    
    for (UIView *view in self.tabBarController.tabBar.subviews) {
        if ([view isKindOfClass:[UIImageView class]] && CGRectGetHeight(view.frame) < 2) {
            view.backgroundColor = [FootblAppearance colorForView:FootblColorTabBarSeparator];
        }
    }
    
    if ([FTAuthenticationManager sharedManager].authenticationType == FTAuthenticationTypeAnonymous) {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
