//
//  ProfileViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "Championship.h"
#import "FootblAPI.h"
#import "ProfileChampionshipTableViewCell.h"
#import "ProfileTableViewCell.h"
#import "ProfileViewController.h"
#import "SettingsViewController.h"
#import "User.h"
#import "Wallet.h"
#import "WalletHighestTableViewCell.h"
#import "WalletTableViewCell.h"

@interface ProfileViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSNumber *totalWallet;
@property (strong, nonatomic) NSNumber *numberOfWallets;
@property (strong, nonatomic) NSArray *championships;

@end

#pragma mark ProfileViewController

@implementation ProfileViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

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
    
    [[User currentUser] updateWithSuccess:^{
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
                    User *user = [User currentUser];
                    profileCell.nameLabel.text = user.name;
                    profileCell.usernameLabel.text = user.username;
                    profileCell.verified = user.verifiedValue;
                    [profileCell.profileImageView setImageWithURL:[NSURL URLWithString:user.picture] placeholderImage:profileCell.placeholderImage];
                    
                    NSDateFormatter *formatter = [NSDateFormatter new];
                    formatter.dateFormat = NSLocalizedString(@"'Since' MMMM YYYY", @"Since {month format} {year format}");
                    profileCell.dateLabel.text = [formatter stringFromDate:user.createdAt];
                    
                    profileCell.verified = YES;
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
        default:
            break;
    }
}

#pragma mark - Delegates & Data sources

#pragma mark - UITableView data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1 && self.championships.count > 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 10)];
        view.backgroundColor = self.tableView.backgroundColor;
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 9.5, CGRectGetWidth(view.frame), 0.5)];
        separatorView.backgroundColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.83 alpha:1];
        separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [view addSubview:separatorView];
        
        return view;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1 && self.championships.count > 0) {
        return 10;
    } else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 3;
        case 1:
            return self.championships.count;
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
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.tableView registerClass:[ProfileTableViewCell class] forCellReuseIdentifier:@"ProfileCell"];
    [self.tableView registerClass:[WalletTableViewCell class] forCellReuseIdentifier:@"WalletCell"];
    [self.tableView registerClass:[WalletHighestTableViewCell class] forCellReuseIdentifier:@"WalletHighestCell"];
    [self.tableView registerClass:[ProfileChampionshipTableViewCell class] forCellReuseIdentifier:@"ChampionshipCell"];
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
