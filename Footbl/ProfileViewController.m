//
//  ProfileViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "Bet.h"
#import "Championship.h"
#import "FavoritesViewController.h"
#import "FootblAPI.h"
#import "Match.h"
#import "Match+Sharing.h"
#import "MatchTableViewCell.h"
#import "NSNumber+Formatter.h"
#import "ProfileChampionshipTableViewCell.h"
#import "ProfileTableViewCell.h"
#import "ProfileViewController.h"
#import "SettingsViewController.h"
#import "Team.h"
#import "TeamImageView.h"
#import "UILabel+MaxFontSize.h"
#import "User.h"
#import "Wallet.h"
#import "WalletHighestTableViewCell.h"
#import "WalletTableViewCell.h"

@interface ProfileViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSNumber *totalWallet;
@property (strong, nonatomic) NSNumber *numberOfWallets;
@property (strong, nonatomic) NSNumber *maxWallet;
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
    if (self.shouldShowSettings) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Settings", @"") style:UIBarButtonItemStylePlain target:self action:@selector(settingsAction:)];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)setShouldShowFavorites:(BOOL)shouldShowFavorites {
    _shouldShowFavorites = shouldShowFavorites;
    if (self.shouldShowFavorites) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Favorites", @"") style:UIBarButtonItemStylePlain target:self action:@selector(favoritesAction:)];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
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
        self.maxWallet = @0;
        self.wallets = @[];
        self.bets = @[];
        [self.tableView reloadData];
        return;
    }
    
    self.numberOfWallets = @(self.user.wallets.count);
    self.totalWallet = [self.user.wallets valueForKeyPath:@"@sum.funds"];
    self.maxWallet = [self.user.wallets valueForKeyPath:@"@max.maxFunds"];
    self.wallets = [self.user.wallets.allObjects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"championship.edition" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"championship.name" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"rid" ascending:YES]]];
    
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
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
            [alert show];
        }
    };
    
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
                    profileCell.starImageView.hidden = self.user.isMe;
                    profileCell.aboutText = self.user.about;
                    [profileCell.profileImageView setImageWithURL:[NSURL URLWithString:self.user.picture] placeholderImage:profileCell.placeholderImage];
                    
                    NSDateFormatter *formatter = [NSDateFormatter new];
                    formatter.dateFormat = NSLocalizedString(@"'Since' MMMM YYYY", @"Since {month format} {year format}");
                    profileCell.dateLabel.text = [formatter stringFromDate:self.user.createdAt];
                    break;
                }
                case 1: {
                    WalletTableViewCell *walletCell = (WalletTableViewCell *)cell;
                    walletCell.valueText = self.totalWallet.stringValue;
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
#warning Add highest value & Date
                    WalletHighestTableViewCell *walletCell = (WalletHighestTableViewCell *)cell;
                    if (self.maxWallet) {
                        [walletCell setHighestValue:self.maxWallet withDate:[NSDate date]];
                    } else {
                        [walletCell setHighestValue:@0 withDate:[NSDate date]];
                    }
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
            championshipCell.nameLabel.text = championship.name;
            championshipCell.informationLabel.text = [NSString stringWithFormat:@"%@, %@", championship.displayCountry, championship.edition.stringValue];
            if (wallet.ranking) {
                championshipCell.rankingLabel.text = wallet.ranking.rankingStringValue;
            } else {
                championshipCell.rankingLabel.text = @"";
            }
            break;
        }
        case 2: {
            Match *match = [self.bets[indexPath.row] match];
            MatchTableViewCell *matchCell = (MatchTableViewCell *)cell;
            matchCell.hostNameLabel.text = match.host.displayName;
            matchCell.hostPotLabel.text = @"0";
            [matchCell.hostImageView setImageWithURL:[NSURL URLWithString:match.host.picture]];
            [matchCell.hostDisabledImageView setImageWithURL:[NSURL URLWithString:match.host.picture]];
            matchCell.drawPotLabel.text = @"0";
            matchCell.guestNameLabel.text = match.guest.displayName;
            [matchCell.guestImageView setImageWithURL:[NSURL URLWithString:match.guest.picture]];
            [matchCell.guestDisabledImageView setImageWithURL:[NSURL URLWithString:match.guest.picture]];
            matchCell.guestPotLabel.text = @"0";
            matchCell.hostScoreLabel.text = match.hostScore.stringValue;
            matchCell.guestScoreLabel.text = match.guestScore.stringValue;
            
            CGFloat potTotal = match.potHostValue + match.potGuestValue + match.potDrawValue;
            
            NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
            numberFormatter.maximumFractionDigits = 2;
            numberFormatter.minimumFractionDigits = 0;
            
            if (match.potHostValue > 0) {
                matchCell.hostPotLabel.text = [numberFormatter stringFromNumber:@(potTotal / match.potHostValue)];
            }
            if (match.potDrawValue > 0) {
                matchCell.drawPotLabel.text = [numberFormatter stringFromNumber:@(potTotal / match.potDrawValue)];
            }
            if (match.potGuestValue > 0) {
                matchCell.guestPotLabel.text = [numberFormatter stringFromNumber:@(potTotal / match.potGuestValue)];
            }
            
            // Auto-decrease font size to fit bounds
            matchCell.hostNameLabel.font = [UIFont fontWithName:matchCell.hostNameLabel.font.fontName size:matchCell.defaultTeamNameFontSize];
            matchCell.guestNameLabel.font = [UIFont fontWithName:matchCell.guestNameLabel.font.fontName size:matchCell.defaultTeamNameFontSize];
            matchCell.drawLabel.font = [UIFont fontWithName:matchCell.drawLabel.font.fontName size:matchCell.defaultTeamNameFontSize];
            CGFloat maxHostNameSize = matchCell.hostNameLabel.maxFontSizeToFitBounds;
            CGFloat maxGuestNameSize = matchCell.guestNameLabel.maxFontSizeToFitBounds;
            CGFloat maxFontSize = MIN(maxHostNameSize, maxGuestNameSize);
            matchCell.hostNameLabel.font = [UIFont fontWithName:matchCell.hostNameLabel.font.fontName size:maxFontSize];
            matchCell.guestNameLabel.font = [UIFont fontWithName:matchCell.guestNameLabel.font.fontName size:maxFontSize];
            matchCell.drawLabel.font = [UIFont fontWithName:matchCell.drawLabel.font.fontName size:maxFontSize];
            
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.dateStyle = NSDateFormatterShortStyle;
            formatter.timeStyle = NSDateFormatterShortStyle;
            formatter.AMSymbol = @"am";
            formatter.PMSymbol = @"pm";
            formatter.dateFormat = [@"EEEE, " stringByAppendingString:formatter.dateFormat];
            formatter.dateFormat = [formatter.dateFormat stringByReplacingOccurrencesOfString:@", y" withString:@""];
            formatter.dateFormat = [formatter.dateFormat stringByReplacingOccurrencesOfString:@"/y" withString:@""];
            formatter.dateFormat = [formatter.dateFormat stringByReplacingOccurrencesOfString:@"y" withString:@""];
            [matchCell setDateText:[formatter stringFromDate:match.date]];
            
            MatchResult result = (MatchResult)[match betForUser:self.user].resultValue;
            if (match.tempBetValue) {
                result = match.tempBetResult;
            }
            
            switch (result) {
                case MatchResultHost:
                    matchCell.layout = MatchTableViewCellLayoutHost;
                    break;
                case MatchResultGuest:
                    matchCell.layout = MatchTableViewCellLayoutGuest;
                    break;
                case MatchResultDraw:
                    matchCell.layout = MatchTableViewCellLayoutDraw;
                    break;
                default:
                    matchCell.layout = MatchTableViewCellLayoutNoBet;
                    break;
            }
            
            matchCell.stakeValueLabel.text = [match betForUser:self.user].value.stringValue;
            matchCell.returnValueLabel.text = @"-";
            matchCell.profitValueLabel.text = @"-";
            
            if (match.jackpot.integerValue > 0) {
                matchCell.footerLabel.text = [@"$" stringByAppendingString:match.jackpot.shortStringValue];
            } else {
                matchCell.footerLabel.text = @"";
            }
            
            // Just for testing
            [matchCell.hostImageView setImageWithURL:[NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/6954324/Aplicativos/Footbl/Temp/Escudo_COR%402x.png"]];
            [matchCell.hostDisabledImageView setImageWithURL:[NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/6954324/Aplicativos/Footbl/Temp/Escudo_COR%402x.png"]];
            [matchCell.guestImageView setImageWithURL:[NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/6954324/Aplicativos/Footbl/Temp/Escudo_SAN%402x.png"]];
            [matchCell.guestDisabledImageView setImageWithURL:[NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/6954324/Aplicativos/Footbl/Temp/Escudo_SAN%402x.png"]];
            
            if (match.elapsed) {
                matchCell.liveLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Live - %i'", @"Live - {time elapsed}'"), match.elapsed.integerValue];
                matchCell.stateLayout = MatchTableViewCellStateLayoutLive;
            } else if (match.finishedValue) {
                matchCell.liveLabel.text = NSLocalizedString(@"Final", @"");
                matchCell.stateLayout = MatchTableViewCellStateLayoutDone;
            } else {
                matchCell.liveLabel.text = @"";
                matchCell.stateLayout = MatchTableViewCellStateLayoutWaiting;
            }
            
            matchCell.shareButton.hidden = !self.user.isMe;
            
            matchCell.shareBlock = ^(MatchTableViewCell *matchBlockCell) {
                [match shareUsingMatchCell:matchBlockCell viewController:self];
            };
            
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
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 9.5, CGRectGetWidth(view.frame), 0.5)];
        separatorView.backgroundColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.83 alpha:1];
        separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [view addSubview:separatorView];
        
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
            return 3;
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
    
    void(^failureBlock)(NSError *error) = ^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
        [alert show];
    };
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        [[User currentUser] starUser:self.user success:nil failure:failureBlock];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.user.isMe) {
        return;
    }
    
    void(^failureBlock)(NSError *error) = ^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
        [alert show];
    };
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        [[User currentUser] unstarUser:self.user success:nil failure:failureBlock];
    }
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    
    [[User currentUser] updateStarredUsersWithSuccess:nil failure:nil];
    
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
        [self reloadData];
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
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:self.tableView];
    
    [self reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
