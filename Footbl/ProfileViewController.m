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
#import "FootblAPI.h"
#import "Match.h"
#import "Match+Sharing.h"
#import "MatchTableViewCell.h"
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
@property (strong, nonatomic) NSArray *championships;
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

#pragma mark - Instance Methods

- (id)init {
    if (self) {
        self.title = NSLocalizedString(@"Profile", @"");
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title image:[UIImage imageNamed:@"tabbar_btn_profile_inactive"] selectedImage:[UIImage imageNamed:@"tabbar_btn_profile_active"]];
    }
    
    return self;
}

- (IBAction)settingsAction:(id)sender {
    [self.navigationController pushViewController:[SettingsViewController new] animated:YES];
}

- (void)reloadData {
    void(^failure)(NSError *error) = ^(NSError *error) {
        [self.refreshControl endRefreshing];
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
            [alert show];
        }
    };
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Wallet"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"rid" ascending:YES]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"active = %@", @YES];
    NSError *error = nil;
    NSArray *fetchResult = [FootblManagedObjectContext() executeFetchRequest:fetchRequest error:&error];
    self.numberOfWallets = @(fetchResult.count);
    self.totalWallet = [fetchResult valueForKeyPath:@"@sum.funds"];
    self.championships = [[fetchResult valueForKeyPath:@"championship"] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"edition" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"rid" ascending:YES]]];
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Bet"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"match.date" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"match.rid" ascending:YES]];
    fetchResult = [FootblManagedObjectContext() executeFetchRequest:fetchRequest error:&error];
    self.bets = fetchResult;
    
    [self.tableView reloadData];
    
    [self.user updateWithSuccess:^{
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
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
#warning Add highest value
                    WalletHighestTableViewCell *walletCell = (WalletHighestTableViewCell *)cell;
                    [walletCell setHighestValue:self.totalWallet withDate:[NSDate date]];
                }
                default:
                    break;
            }
            break;
        case 1: {
            ProfileChampionshipTableViewCell *championshipCell = (ProfileChampionshipTableViewCell *)cell;
            Championship *championship = self.championships[indexPath.row];
            [championshipCell.championshipImageView setImageWithURL:[NSURL URLWithString:championship.picture] placeholderImage:[UIImage imageNamed:@"generic_group"]];
            championshipCell.nameLabel.text = championship.name;
            championshipCell.informationLabel.text = [NSString stringWithFormat:@"%@, %@", championship.displayCountry, championship.edition.stringValue];
            championshipCell.rankingLabel.text = @"#39,944";
#warning Add ranking text
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
            
            MatchResult result = (MatchResult)match.bet.resultValue;
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
            
            matchCell.stakeValueLabel.text = match.bet.value.stringValue;
            matchCell.returnValueLabel.text = @"-";
            matchCell.profitValueLabel.text = @"-";
            
            if (match.jackpot.integerValue > 0) {
                matchCell.footerLabel.text = [@"$" stringByAppendingString:match.jackpot.stringValue];
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
    if (section == 1 && self.championships.count > 0) {
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
    if (section == 1 && self.championships.count > 0) {
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
            return self.championships.count;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Settings", @"") style:UIBarButtonItemStylePlain target:self action:@selector(settingsAction:)];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    tableViewController.refreshControl = self.refreshControl;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextObjectsDidChangeNotification object:FootblManagedObjectContext() queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if (!self.refreshControl.isRefreshing && [FootblAPI sharedAPI].isAuthenticated) {
            [self reloadData];
        }
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
