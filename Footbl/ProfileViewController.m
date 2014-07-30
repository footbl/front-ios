//
//  ProfileViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "AnonymousViewController.h"
#import "Bet.h"
#import "Championship.h"
#import "FavoritesViewController.h"
#import "FootblAPI.h"
#import "FootblTabBarController.h"
#import "LoadingHelper.h"
#import "Match+Sharing.h"
#import "MatchTableViewCell+Setup.h"
#import "NSNumber+Formatter.h"
#import "ProfileChampionshipTableViewCell.h"
#import "ProfileTableViewCell.h"
#import "ProfileViewController.h"
#import "SettingsViewController.h"
#import "User.h"
#import "Wallet.h"
#import "WalletGraphTableViewCell.h"
#import "WalletHighestTableViewCell.h"
#import "WalletTableViewCell.h"

@interface ProfileViewController ()

@property (strong, nonatomic) AnonymousViewController *anonymousViewController;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSNumber *totalWallet;
@property (strong, nonatomic) NSNumber *numberOfWallets;
@property (strong, nonatomic) Wallet *maxWallet;
@property (strong, nonatomic) NSArray *wallets;
@property (strong, nonatomic) NSArray *bets;

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
    
    if (FBTweakValue(@"UX", @"Profile", @"Search", NO)) {
        self.navigationItem.leftBarButtonItem = nil;
        
        if (self.shouldShowSettings) {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Settings", @"") style:UIBarButtonItemStylePlain target:self action:@selector(settingsAction:)];
        }
    } else {
        self.navigationItem.rightBarButtonItem = nil;
        
        if (self.shouldShowSettings) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Settings", @"") style:UIBarButtonItemStylePlain target:self action:@selector(settingsAction:)];
        }
    }
}

- (void)setShouldShowFavorites:(BOOL)shouldShowFavorites {
    _shouldShowFavorites = shouldShowFavorites;
    
    if (FBTweakValue(@"UX", @"Profile", @"Search", NO)) {
        self.navigationItem.rightBarButtonItem = nil;
        
        if (self.shouldShowFavorites) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Favorites", @"") style:UIBarButtonItemStylePlain target:self action:@selector(favoritesAction:)];
        }
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        
        if (self.shouldShowFavorites) {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Favorites", @"") style:UIBarButtonItemStylePlain target:self action:@selector(favoritesAction:)];
        }
    }
}

#pragma mark - Instance Methods

- (id)init {
    if (self) {
        self.title = NSLocalizedString(@"Profile", @"");
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title image:[UIImage imageNamed:@"tabbar_btn_profile_inactive"] selectedImage:[UIImage imageNamed:@"tabbar_btn_profile_active"]];
    }
    
    return self;
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

- (void)reloadContent {
    if (![FootblAPI sharedAPI].isAuthenticated) {
        self.user = nil;
        self.numberOfWallets = @0;
        self.totalWallet = @0;
        self.maxWallet = nil;
        self.wallets = @[];
        self.bets = @[];
        [self.tableView reloadData];
        return;
    }
    
    self.numberOfWallets = @(self.user.wallets.count);
    self.totalWallet = @([[self.user.wallets valueForKeyPath:@"@sum.funds"] floatValue] + [[self.user.wallets valueForKeyPath:@"@sum.stake"] floatValue]);
    self.maxWallet = [self.user.wallets sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"maxFunds" ascending:NO]]].firstObject;
    self.wallets = [self.user.wallets.allObjects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"championship.edition" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"championship.name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], [NSSortDescriptor sortDescriptorWithKey:@"rid" ascending:YES]]];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Bet"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"match.date" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"match.rid" ascending:NO]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"wallet.rid IN %@", [self.wallets valueForKeyPath:@"rid"]];
    NSArray *fetchResult = [FootblManagedObjectContext() executeFetchRequest:fetchRequest error:nil];
    self.bets = fetchResult;

    [self.tableView reloadData];
    
    if (!self.user.isMe && [self.user isStarredByUser:[User currentUser]]) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)reloadData {
    [super reloadData];
    [self reloadContent];
    
    void(^failure)(NSError *error) = ^(NSError *error) {
        [self reloadContent];
        [self.refreshControl endRefreshing];
        [[LoadingHelper sharedInstance] hideHud];
        [[ErrorHandler sharedInstance] displayError:error];
    };
    
    if (!self.totalWallet.integerValue) {
        [[LoadingHelper sharedInstance] showHud];
    }
    
    [Wallet updateWithUser:self.user.editableObject success:^{
        [self reloadContent];
        __block NSError *error;
        __block NSInteger completedRequests = 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.wallets enumerateObjectsUsingBlock:^(Wallet *wallet, NSUInteger idx, BOOL *stop) {
                [Bet updateWithWallet:wallet.editableObject success:^{
                    completedRequests ++;
                    if (completedRequests == self.wallets.count) {
                        if (error) {
                            failure(error);
                        } else {
                            [self reloadContent];
                            [self.refreshControl endRefreshing];
                            [[LoadingHelper sharedInstance] hideHud];
                        }
                    }
                } failure:^(NSError *newError) {
                    completedRequests ++;
                    error = newError;
                    if (completedRequests == self.wallets.count) {
                        if (failure) failure(error);
                    }
                }];
            }];
        });
    } failure:failure];
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
                    if (self.user.isMe) {
                        profileCell.starImageView.highlightedImage = nil;
                    }
                    profileCell.aboutText = self.user.about;
                    profileCell.followersLabel.text = self.user.followers.shortStringValue;
                    [profileCell.profileImageView setImageWithURL:[NSURL URLWithString:self.user.picture] placeholderImage:profileCell.placeholderImage];
                    
                    NSDateFormatter *formatter = [NSDateFormatter new];
                    formatter.dateFormat = NSLocalizedString(@"'Since' MMMM YYYY", @"Since {month format} {year format}");
                    profileCell.dateLabel.text = [formatter stringFromDate:self.user.createdAt];
                    break;
                }
                case 1: {
                    WalletTableViewCell *walletCell = (WalletTableViewCell *)cell;
                    walletCell.valueText = self.totalWallet.walletStringValue;
                    walletCell.arrowImageView.hidden = YES;
                    walletCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    if (self.numberOfWallets.integerValue == 1) {
                        walletCell.leaguesLabel.text = NSLocalizedString(@"Betting in 1 league", @"");
                    } else {
                        walletCell.leaguesLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Betting in %i leagues", @"Betting in {number of leagues} leagues"), self.numberOfWallets.integerValue];
                    }
                    break;
                }
                case 2: {
                    WalletHighestTableViewCell *walletCell = (WalletHighestTableViewCell *)cell;
                    if (self.maxWallet) {
                        [walletCell setHighestValue:self.maxWallet.maxFunds withDate:self.maxWallet.maxFundsDate];
                    } else {
                        [walletCell setHighestValue:@0 withDate:[NSDate date]];
                    }
                    break;
                }
                case 3: {
                    WalletGraphTableViewCell *walletCell = (WalletGraphTableViewCell *)cell;
                    walletCell.dataSource = self.maxWallet.lastActiveRounds;
                    walletCell.roundsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Wallet evolution", @""), walletCell.dataSource];
                    break;
                }
                default:
                    break;
            }
            break;
        case 1: {
            ProfileChampionshipTableViewCell *championshipCell = (ProfileChampionshipTableViewCell *)cell;
            Wallet *wallet = self.wallets[indexPath.row];
            Championship *championship = wallet.championship;
            [championshipCell.championshipImageView setImageWithURL:[NSURL URLWithString:championship.picture] placeholderImage:[UIImage imageNamed:@"generic_group"]];
            championshipCell.nameLabel.text = championship.displayName;
            championshipCell.informationLabel.text = [NSString stringWithFormat:@"%@, %@", championship.displayCountry, championship.edition.stringValue];
            if (wallet.ranking) {
                championshipCell.rankingLabel.text = wallet.ranking.rankingStringValue;
            } else {
                championshipCell.rankingLabel.text = @"";
            }
            break;
        }
        case 2: {
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
    if (section == 1 && self.wallets.count > 0) {
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
    if (section == 1 && self.wallets.count > 0) {
        return 10;
    } else if (section == 2 && self.bets.count > 0) {
        return 7;
    } else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 3 + (FBTweakValue(@"UX", @"Profile", @"Graph", NO) && self.maxWallet.lastActiveRounds.count >= 3 ? 1 : 0);
        case 1:
            return self.wallets.count;
        case 2:
            return self.bets.count;
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
            identifier = @"ChampionshipCell";
            break;
        case 2:
            identifier = @"MatchCell";
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
            return 67;
        case 2: {
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
    if (self.user.isMe) {
        return;
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        [[User currentUser] starUser:self.user success:nil failure:[ErrorHandler failureBlock]];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.user.isMe) {
        return;
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        [[User currentUser] unstarUser:self.user success:nil failure:[ErrorHandler failureBlock]];
    }
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    
    [[User currentUser] updateStarredUsersWithSuccess:nil failure:nil];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kFootblAPINotificationAuthenticationChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        self.user = nil;
        [self reloadData];
        
        if ([FootblAPI sharedAPI].authenticationType == FootblAuthenticationTypeAnonymous) {
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
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 5)];
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
    
    if ([FootblAPI sharedAPI].authenticationType == FootblAuthenticationTypeAnonymous) {
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
