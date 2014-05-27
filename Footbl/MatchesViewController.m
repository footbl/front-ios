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
#import "LoadingHelper.h"
#import "Match.h"
#import "Match+Sharing.h"
#import "MatchTableViewCell.h"
#import "MatchesNavigationBarView.h"
#import "MatchesViewController.h"
#import "NSNumber+Formatter.h"
#import "Team.h"
#import "TeamImageView.h"
#import "UILabel+MaxFontSize.h"
#import "User.h"
#import "Wallet.h"

static CGFloat kScrollMinimumVelocityToToggleTabBar = 300.f;
static CGFloat kWalletMaximumFundsToAllowBet = 20;

@interface MatchesViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (assign, nonatomic) CGPoint tableViewOffset;
@property (strong, nonatomic) MatchesNavigationBarView *navigationBarTitleView;
@property (assign, nonatomic) NSInteger numberOfMatches;

@end

#pragma mark MatchesViewController

@implementation MatchesViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

@synthesize championship = _championship;

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Match"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"rid" ascending:YES]];
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

- (Championship *)championship {
    if (!_championship) {
        [self fetchChampionship];
    }
    return _championship;
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

- (IBAction)rechargeWalletAction:(id)sender {
    if (self.championship.myWallet.localFunds.integerValue + self.championship.myWallet.localStake.integerValue > kWalletMaximumFundsToAllowBet) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Ops", @"") message:NSLocalizedString(@"Cannot update wallet due to wallet balance", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alert show]; 
        return;
    }
    
    [self.championship.myWallet rechargeWithSuccess:^{
        [self reloadWallet];
    } failure:^(NSError *error) {
        SPLogError(@"%@", error);
        [[ErrorHandler sharedInstance] displayError:error];
    }];
}

- (void)configureCell:(MatchTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Match *match = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.hostNameLabel.text = match.host.displayName;
    [cell.hostImageView setImageWithURL:[NSURL URLWithString:match.host.picture]];
    [cell.hostDisabledImageView setImageWithURL:[NSURL URLWithString:match.host.picture]];
    cell.guestNameLabel.text = match.guest.displayName;
    [cell.guestImageView setImageWithURL:[NSURL URLWithString:match.guest.picture]];
    [cell.guestDisabledImageView setImageWithURL:[NSURL URLWithString:match.guest.picture]];
    cell.hostScoreLabel.text = match.hostScore.stringValue;
    cell.guestScoreLabel.text = match.guestScore.stringValue;
    
    CGFloat potTotal = MAX(1, match.jackpotValue);
    NSNumber *potHost = @(potTotal / match.potHostValue);
    NSNumber *potDraw = @(potTotal / match.potDrawValue);
    NSNumber *potGuest = @(potTotal / match.potGuestValue);
    
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    numberFormatter.maximumFractionDigits = 2;
    numberFormatter.minimumFractionDigits = 0;
    
    cell.hostPotLabel.text = [numberFormatter stringFromNumber:potHost];
    cell.drawPotLabel.text = [numberFormatter stringFromNumber:potDraw];
    cell.guestPotLabel.text = [numberFormatter stringFromNumber:potGuest];
    
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
    
    __block Bet *bet = [match myBet];
    MatchResult result = (MatchResult)bet.resultValue;
    if (match.tempBetValue) {
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
    
    if (match.tempBetValue) {
        if (match.tempBetValue.integerValue == 0) {
            cell.stakeValueLabel.text = @"-";
            cell.returnValueLabel.text = @"-";
        } else {
            cell.stakeValueLabel.text = match.tempBetValue.stringValue;
            if (match.tempBetResult == MatchResultHost) {
                cell.returnValueLabel.text = @((int)(potHost.floatValue * match.tempBetValue.floatValue)).stringValue;
            } else if (match.tempBetResult == MatchResultGuest) {
                cell.returnValueLabel.text = @((int)(potGuest.floatValue * match.tempBetValue.floatValue)).stringValue;
            } else {
                cell.returnValueLabel.text = @((int)(potDraw.floatValue * match.tempBetValue.floatValue)).stringValue;
            }
        }
        cell.profitValueLabel.text = @"-";
    } else if (bet) {
        cell.stakeValueLabel.text = bet.value.stringValue;
        cell.returnValueLabel.text = bet.toReturn.stringValue;
        if (match.finishedValue) {
            cell.profitValueLabel.text = bet.reward.stringValue;
        } else {
            cell.profitValueLabel.text = @"-";
        }
    } else {
        cell.stakeValueLabel.text = @"-";
        cell.returnValueLabel.text = @"-";
        cell.profitValueLabel.text = @"-";
    }
    
    cell.selectionBlock = ^(NSInteger index){
        if (match.isBetSyncing || match.finishedValue || match.elapsed) {
            return;
        }
        
        bet = [match myBet];
        
        NSInteger currentBet = bet.valueValue;
        MatchResult result = (MatchResult)bet.result.integerValue;
        if (match.tempBetValue) {
            currentBet = match.tempBetValue.integerValue;
            result = match.tempBetResult;
        }
        
        switch (index) {
            case 0: // Host
                if (result == MatchResultHost) {
                    currentBet ++;
                } else if (currentBet == 0) {
                    currentBet = 1;
                    result = MatchResultHost;
                } else {
                    currentBet --;
                }
                break;
            case 1: // Draw
                if (result == MatchResultDraw) {
                    currentBet ++;
                } else if (currentBet == 0) {
                    currentBet = 1;
                    result = MatchResultDraw;
                } else {
                    currentBet --;
                }
                break;
            case 2: // Guest
                if (result == MatchResultGuest) {
                    currentBet ++;
                } else if (currentBet == 0) {
                    currentBet = 1;
                    result = MatchResultGuest;
                } else {
                    currentBet --;
                }
                break;
        }
        if (currentBet == 0) {
            result = 0;
        }
        match.tempBetValue = @(currentBet);
        match.tempBetResult = result;
        
        FootblAPIFailureBlock failure = ^(NSError *error) {
            [[ErrorHandler sharedInstance] displayError:error];
            [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] delay:[FootblAppearance speedForAnimation:FootblAnimationDefault] options:UIViewAnimationOptionAllowUserInteraction animations:^{
                [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            } completion:nil];
            [self reloadWallet];
        };
        
        if (result == 0) {
            [bet.editableObject deleteWithSuccess:nil failure:failure];
        } else if (bet) {
            [bet.editableObject updateWithBid:@(currentBet) result:result success:nil failure:failure];
        } else {
            [Bet createWithMatch:match.editableObject bid:@(currentBet) result:result success:nil failure:failure];
        }
        
        [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] animations:^{
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
        }];
        
        [self reloadWallet];
    };
    
    if (match.jackpot.integerValue > 0) {
        [cell setFooterText:[NSLocalizedString(@"$", @"") stringByAppendingString:match.jackpot.shortStringValue]];
        cell.footerLabel.hidden = NO;
    } else {
        [cell setFooterText:[NSLocalizedString(@"$", @"") stringByAppendingString:@"0"]];
        cell.footerLabel.hidden = YES;
    }
    
    // Just for testing
    [cell.hostImageView setImageWithURL:[NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/6954324/Aplicativos/Footbl/Temp/Escudo_COR%402x.png"]];
    [cell.hostDisabledImageView setImageWithURL:[NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/6954324/Aplicativos/Footbl/Temp/Escudo_COR%402x.png"]];
    [cell.guestImageView setImageWithURL:[NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/6954324/Aplicativos/Footbl/Temp/Escudo_SAN%402x.png"]];
    [cell.guestDisabledImageView setImageWithURL:[NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/6954324/Aplicativos/Footbl/Temp/Escudo_SAN%402x.png"]];
    
    if (match.elapsed) {
        cell.liveLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Live - %i'", @"Live - {time elapsed}'"), match.elapsed.integerValue];
        cell.stateLayout = MatchTableViewCellStateLayoutLive;
    } else if (match.finishedValue) {
        cell.liveLabel.text = NSLocalizedString(@"Final", @"");
        cell.stateLayout = MatchTableViewCellStateLayoutDone;
    } else {
        cell.liveLabel.text = @"";
        cell.stateLayout = MatchTableViewCellStateLayoutWaiting;
    }
    
    cell.shareBlock = ^(MatchTableViewCell *matchCell) {
        [match shareUsingMatchCell:matchCell viewController:self];
    };
}

- (void)fetchChampionship {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Championship"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"ANY wallets.user.rid = %@ AND ANY wallets.active = %@", [User currentUser].rid, @YES];
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
    
    if (self.championship.myWallet) {
        [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] animations:^{
            for (UILabel *label in labels) {
                label.alpha = 1;
            }
        }];
        self.navigationBarTitleView.walletValueLabel.text = self.championship.myWallet.localFunds.shortStringValue;
        self.navigationBarTitleView.stakeValueLabel.text = self.championship.myWallet.localStake.stringValue;
        self.navigationBarTitleView.returnValueLabel.text = self.championship.myWallet.toReturn.stringValue;
        self.navigationBarTitleView.profitValueLabel.text = self.championship.myWallet.profit.stringValue;
    } else {
        for (UILabel *label in labels) {
            label.text = @"";
            label.alpha = 0;
        }
    }
    
    if (self.championship.myWallet.localFunds.integerValue + self.championship.myWallet.localStake.integerValue <= kWalletMaximumFundsToAllowBet) {
        UIImage *rechargeImage = [UIImage imageNamed:@"btn_recharge_money"];
        if ([self.navigationBarTitleView.moneyButton imageForState:UIControlStateNormal] != rechargeImage) {
            [self.navigationBarTitleView.moneyButton setImage:rechargeImage forState:UIControlStateNormal];
        }
    } else {
        [self.navigationBarTitleView.moneyButton setImage:[UIImage imageNamed:@"money_sign"] forState:UIControlStateNormal];
    }
    
    CGFloat fontSize = MIN(self.navigationBarTitleView.walletValueLabel.maxFontSizeToFitBounds, self.navigationBarTitleView.defaultValueFontSize);
    UIFont *font = [UIFont fontWithName:self.navigationBarTitleView.walletValueLabel.font.fontName size:fontSize];
    [labels makeObjectsPerformSelector:@selector(setFont:) withObject:font];
}

- (void)scrollToFirstActiveMatchAnimated:(BOOL)animated {
    Match *match = [self.fetchedResultsController.fetchedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"finished = %@", @NO]].firstObject;
    if (!match) {
        match = self.fetchedResultsController.fetchedObjects.lastObject;
    }
    
    [self.tableView scrollToRowAtIndexPath:[self.fetchedResultsController indexPathForObject:match] atScrollPosition:UITableViewScrollPositionTop animated:animated];
}

- (void)reloadData {
    [super reloadData];
    
    NSInteger matches = self.fetchedResultsController.fetchedObjects.count;
    
    void(^failure)(NSError *error) = ^(NSError *error) {
        [self.refreshControl endRefreshing];
        if (matches == 0) {
            [[LoadingHelper sharedInstance] hideHud];
        }
        [[ErrorHandler sharedInstance] displayError:error];
    };
    
    self.numberOfMatches = matches;
    if (matches == 0) {
        [[LoadingHelper sharedInstance] showHud];
    }
    [Wallet updateWithUser:[User currentUser] success:^{
        [self fetchChampionship];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.championship ? 0.1 : 0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!self.championship) {
                [self fetchChampionship];
            }
            if (self.championship) {
                [Wallet ensureWalletWithChampionship:self.championship.editableObject success:^{
                    [Match updateFromChampionship:self.championship.editableObject success:^{
                        [Bet updateWithWallet:self.championship.myWallet.editableObject success:^{
                            [self.refreshControl endRefreshing];
                            if (matches == 0) {
                                [[LoadingHelper sharedInstance] hideHud];
                            }
                        } failure:failure];
                    } failure:failure];
                } failure:failure];
            } else {
                if (matches == 0) {
                    [[LoadingHelper sharedInstance] hideHud];
                }
                [self.refreshControl endRefreshing];
            }
        });
    } failure:failure];
}

- (NSTimeInterval)updateInterval {
    Match *match = [self.fetchedResultsController.fetchedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"finished = %@", @NO]].firstObject;
    if (match && (match.elapsed || [match.date timeIntervalSinceDate:[NSDate date]] < UPDATE_INTERVAL)) {
        return 60;
    }
    
    return [super updateInterval];
}

#pragma mark - Delegates & Data sources

#pragma mark - NSFetchedResultsController delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [super controllerDidChangeContent:controller];
    
    if (self.numberOfMatches == 0 && controller.fetchedObjects.count > 0) {
        self.numberOfMatches = controller.fetchedObjects.count;
        [self scrollToFirstActiveMatchAnimated:NO];
    }
}

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
    Match *match = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (match.elapsed || match.finishedValue) {
        return 363;
    } else {
        return 340;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.numberOfMatches = self.fetchedResultsController.fetchedObjects.count;
    
    self.navigationBarTitleView = [[MatchesNavigationBarView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 80)];
    [self.navigationBarTitleView.moneyButton addTarget:self action:@selector(rechargeWalletAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.navigationBarTitleView];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    tableViewController.refreshControl = self.refreshControl;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextObjectsDidChangeNotification object:FootblManagedObjectContext() queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self reloadWallet];
        if (!self.refreshControl.isRefreshing && (!self.championship || self.championship.isDeleted) && [FootblAPI sharedAPI].isAuthenticated) {
            [self.refreshControl beginRefreshing];
            [self reloadData];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kFootblAPINotificationAuthenticationChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        self.championship = nil;
        [self reloadWallet];
        [self reloadData];
    }];
    
    self.tableView = tableViewController.tableView;
    self.tableView.frame = self.view.frame;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(CGRectGetHeight(self.navigationBarTitleView.frame), 0, 0, 0);
    self.tableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.navigationBarTitleView.frame), 0, 0, 0);
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 15)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 5)];
    [self.tableView registerClass:[MatchTableViewCell class] forCellReuseIdentifier:@"MatchCell"];
    [self.view insertSubview:self.tableView belowSubview:self.navigationBarTitleView];
    
    [self reloadWallet];
    [self reloadData];
    
    [self scrollToFirstActiveMatchAnimated:NO];
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
