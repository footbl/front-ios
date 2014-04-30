//
//  MatchesViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/27/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "Bet.h"
#import "Championship.h"
#import "FootblTabBarController.h"
#import "Match.h"
#import "MatchTableViewCell.h"
#import "MatchesNavigationBarView.h"
#import "MatchesViewController.h"
#import "Team.h"
#import "TeamsViewController.h"
#import "TeamImageView.h"
#import "UILabel+MaxFontSize.h"
#import "Wallet.h"

static CGFloat kScrollMinimumVelocityToToggleTabBar = 300.f;

@interface MatchesViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (assign, nonatomic) CGPoint tableViewOffset;
@property (strong, nonatomic) MatchesNavigationBarView *navigationBarTitleView;

@end

#pragma mark MatchesViewController

@implementation MatchesViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Match"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"championship = %@", self.championship];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:FootblManagedObjectContext() sectionNameKeyPath:nil cacheName:nil];
        self.fetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![_fetchedResultsController performFetch:&error]) {
            SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return _fetchedResultsController;
}

- (void)setChampionship:(Championship *)championship {
    _championship = championship;
    self.fetchedResultsController = nil;
    [self.tableView reloadData];
}

#pragma mark - Instance Methods

- (id)init {
    if (self) {
        self.title = NSLocalizedString(@"Matches", @"");
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title image:[UIImage imageNamed:@"tabbar_btn_matches_ainctive"] selectedImage:[UIImage imageNamed:@"tabbar_btn_matches_active"]];
        [self fetchChampionship];
    }
    
    return self;
}

- (void)configureCell:(MatchTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Match *match = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.hostNameLabel.text = match.host.name;
    cell.hostPotLabel.text = match.potHost.stringValue;
    [cell.hostImageView setImageWithURL:[NSURL URLWithString:match.host.picture]];
    [cell.hostDisabledImageView setImageWithURL:[NSURL URLWithString:match.host.picture]];
    cell.drawPotLabel.text = match.potDraw.stringValue;
    cell.guestNameLabel.text = match.guest.name;
    [cell.guestImageView setImageWithURL:[NSURL URLWithString:match.guest.picture]];
    [cell.guestDisabledImageView setImageWithURL:[NSURL URLWithString:match.guest.picture]];
    cell.guestPotLabel.text = match.potGuest.stringValue;
    
    // Auto-decrease font size to fit bounds
    cell.hostNameLabel.font = [UIFont fontWithName:cell.hostNameLabel.font.fontName size:cell.defaultTeamNameFontSize];
    cell.guestNameLabel.font = [UIFont fontWithName:cell.guestNameLabel.font.fontName size:cell.defaultTeamNameFontSize];
    cell.drawLabel.font = [UIFont fontWithName:cell.drawLabel.font.fontName size:cell.defaultTeamNameFontSize];
    CGFloat maxHostNameSize = cell.hostNameLabel.maxFontSizeToFitBounds;
    CGFloat maxGuestNameSize = cell.guestNameLabel.maxFontSizeToFitBounds;
    CGFloat maxFontSize = MIN(maxHostNameSize, maxGuestNameSize);
    cell.hostNameLabel.font = [UIFont fontWithName:cell.hostNameLabel.font.fontName size:maxFontSize];
    cell.guestNameLabel.font = [UIFont fontWithName:cell.guestNameLabel.font.fontName size:maxFontSize];
    cell.drawLabel.font = [UIFont fontWithName:cell.drawLabel.font.fontName size:maxFontSize];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    formatter.AMSymbol = @"am";
    formatter.PMSymbol = @"pm";
    formatter.dateFormat = [@"EEEE, " stringByAppendingString:formatter.dateFormat];
    formatter.dateFormat = [formatter.dateFormat stringByReplacingOccurrencesOfString:@", y" withString:@""];
    formatter.dateFormat = [formatter.dateFormat stringByReplacingOccurrencesOfString:@"/y" withString:@""];
    formatter.dateFormat = [formatter.dateFormat stringByReplacingOccurrencesOfString:@"y" withString:@""];
    [cell setDateText:[formatter stringFromDate:match.date]];
    
    MatchResult result = (MatchResult)match.bet.resultValue;
    if (match.isBetSyncing) {
        result = match.tempBetResult;
    }
    
    switch (result) {
        case MatchResultHost:
            cell.layout = MatchTableViewCellLayoutHost;
            break;
        case MatchResultGuest:
            cell.layout = MatchTableViewCellLayoutGuest;
            break;
        case MatchResultDraw:
            cell.layout = MatchTableViewCellLayoutDraw;
            break;
        default:
            cell.layout = MatchTableViewCellLayoutNoBet;
            break;
    }
    
    if (match.isBetSyncing) {
        if (match.tempBetValue.integerValue == 0) {
            cell.stakeValueLabel.text = @"-";
        } else {
            cell.stakeValueLabel.text = match.tempBetValue.stringValue;
        }
        cell.returnValueLabel.text = @"-";
        cell.profitValueLabel.text = @"-";
    } else if (match.bet) {
        cell.stakeValueLabel.text = match.bet.value.stringValue;
        cell.returnValueLabel.text = @"-";
        cell.profitValueLabel.text = @"-";
    } else {
        cell.stakeValueLabel.text = @"-";
        cell.returnValueLabel.text = @"-";
        cell.profitValueLabel.text = @"-";
    }
    
    // Just for testing
    [cell.hostImageView setImageWithURL:[NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/6954324/Aplicativos/Footbl/Temp/Escudo_COR%402x.png"]];
    [cell.hostDisabledImageView setImageWithURL:[NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/6954324/Aplicativos/Footbl/Temp/Escudo_COR%402x.png"]];
    [cell.guestImageView setImageWithURL:[NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/6954324/Aplicativos/Footbl/Temp/Escudo_FCB%402x.png"]];
    [cell.guestDisabledImageView setImageWithURL:[NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/6954324/Aplicativos/Footbl/Temp/Escudo_FCB%402x.png"]];
    cell.hostPotLabel.text = @"1.21";
    cell.drawPotLabel.text = @"8.32";
    cell.guestPotLabel.text = @"18.03";
    [cell setStakesCount:@143 commentsCount:@48];
    
    switch (indexPath.row) {
        case 0:
            cell.liveLabel.text = @"";
            cell.stateLayout = MatchTableViewCellStateLayoutWaiting;
            break;
        case 1:
            cell.liveLabel.text = @"";
            cell.stateLayout = MatchTableViewCellStateLayoutWaiting;
            break;
        case 2:
            cell.liveLabel.text = @"Ao vivo - 87'";
            cell.stateLayout = MatchTableViewCellStateLayoutLive;
            [cell setDateText:NSLocalizedString(@"Now", @"")];
            break;
        default:
            cell.liveLabel.text = @"";
            cell.stateLayout = MatchTableViewCellStateLayoutDone;
            break;
    }
}

- (void)fetchChampionship {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Championship"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"wallet.active = %@", @YES];
    NSError *error = nil;
    NSArray *fetchResult = [FootblManagedObjectContext() executeFetchRequest:fetchRequest error:&error];
    if (error) {
        SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    self.championship = fetchResult.firstObject;
}

- (void)reloadWallet {
    NSArray *labels = @[self.navigationBarTitleView.walletValueLabel, self.navigationBarTitleView.stakeValueLabel, self.navigationBarTitleView.returnValueLabel, self.navigationBarTitleView.profitValueLabel];
    
    if (self.championship.wallet) {
        [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] animations:^{
            for (UILabel *label in labels) {
                label.alpha = 1;
            }
        }];
        self.navigationBarTitleView.walletValueLabel.text = [@"$" stringByAppendingString:self.championship.wallet.funds.stringValue];
        self.navigationBarTitleView.stakeValueLabel.text = self.championship.wallet.stake.stringValue;
        self.navigationBarTitleView.returnValueLabel.text = self.championship.wallet.toReturn.stringValue;
        self.navigationBarTitleView.profitValueLabel.text = self.championship.wallet.profit.stringValue;
    } else {
        for (UILabel *label in labels) {
            label.text = @"";
            label.alpha = 0;
        }
    }
}

- (void)reloadData {
    void(^failure)(NSError *error) = ^(NSError *error) {
        [self.refreshControl endRefreshing];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
        [alert show];
    };
    
    [Wallet updateWithSuccess:^{
        [self fetchChampionship];
        if (self.championship) {
            [Wallet ensureWalletWithChampionship:self.championship.editableObject success:^{
                [Match updateFromChampionship:self.championship.editableObject success:^{
                    [Bet updateWithWallet:self.championship.wallet.editableObject success:^{
                        [self.refreshControl endRefreshing];
                    } failure:failure];
                } failure:failure];
            } failure:nil];
        }
    } failure:failure];
}

#pragma mark - Delegates & Data sources

#pragma mark - UIScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.tableViewOffset = scrollView.contentOffset;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    FootblTabBarController *tabBarController = (FootblTabBarController *)self.tabBarController;
    
    CGFloat tabBarHeight = CGRectGetHeight(tabBarController.tabBar.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    CGFloat velocityY = [scrollView.panGestureRecognizer velocityInView:self.view].y;
    CGFloat tabBarInsetTop = 20.f;
    
    BOOL isContentBehindTabBar = scrollView.contentSize.height - scrollView.contentOffset.y < viewHeight + tabBarInsetTop + tabBarHeight * 3;
    if (viewHeight < scrollView.contentSize.height && (velocityY < -kScrollMinimumVelocityToToggleTabBar || isContentBehindTabBar) && scrollView.contentOffset.y > 20) {
        [tabBarController setTabBarHidden:YES animated:YES];
        [self.navigationBarTitleView setTitleHidden:YES animated:YES];
    } else if (viewHeight > scrollView.contentSize.height || (velocityY > kScrollMinimumVelocityToToggleTabBar * 2.5 && !isContentBehindTabBar) || scrollView.contentOffset.y < 20) {
        [tabBarController setTabBarHidden:NO animated:YES];
        [self.navigationBarTitleView setTitleHidden:NO animated:YES];
    }
}

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MatchTableViewCell *cell = (MatchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MatchCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            return 380;
        case 1:
            return 380;
        case 2:
            return 433;
        default:
            return 406;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Match *match = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (match.isBetSyncing) {
        return;
    }
    
    FootblAPIFailureBlock failure = ^(NSError *error) {
        [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] delay:[FootblAppearance speedForAnimation:FootblAnimationDefault] options:UIViewAnimationOptionAllowUserInteraction animations:^{
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
        } completion:nil];
    };
    
    if (match.bet && match.bet.resultValue == MatchResultDraw) {
        [match.bet.editableObject deleteWithSuccess:nil failure:failure];
    } else {
        MatchResult result;
        if (match.bet.resultValue == MatchResultHost) {
            result = MatchResultGuest;
        } else if (match.bet.resultValue == MatchResultGuest) {
            result = MatchResultDraw;
        } else {
            result = MatchResultHost;
        }
        
        if (match.bet) {
            [match.bet.editableObject updateWithBid:@10 result:result success:nil failure:failure];
        } else {
            [Bet createWithMatch:match.editableObject bid:@10 result:result success:nil failure:failure];
        }
    }
    
    [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] animations:^{
       [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
    }];
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.navigationBarTitleView = [[MatchesNavigationBarView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 80)];
    [self.view addSubview:self.navigationBarTitleView];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    tableViewController.refreshControl = self.refreshControl;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextObjectsDidChangeNotification object:FootblManagedObjectContext() queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self reloadWallet];
        if (!self.refreshControl.isRefreshing && (!self.championship || self.championship.isDeleted)) {
            [self.refreshControl beginRefreshing];
            [self reloadData];
        }
    }];
    
    self.tableView = tableViewController.tableView;
    self.tableView.frame = self.view.frame;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 380;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(CGRectGetHeight(self.navigationBarTitleView.frame), 0, 0, 0);
    self.tableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.navigationBarTitleView.frame), 0, 0, 0);
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 15)];
    [self.tableView registerClass:[MatchTableViewCell class] forCellReuseIdentifier:@"MatchCell"];
    [self.view insertSubview:self.tableView belowSubview:self.navigationBarTitleView];
    
    [self reloadWallet];
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
