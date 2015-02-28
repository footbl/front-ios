//
//  MatchesViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/27/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <SPHipster/SPHipster.h>
#import "Bet.h"
#import "BetsViewController.h"
#import "Championship.h"
#import "FootblPopupViewController.h"
#import "FootblTabBarController.h"
#import "FTAuthenticationManager.h"
#import "LoadingHelper.h"
#import "Match.h"
#import "MatchTableViewCell+Setup.h"
#import "MatchesNavigationBarView.h"
#import "MatchesViewController.h"
#import "NSNumber+Formatter.h"
#import "RechargeButton.h"
#import "RechargeViewController.h"
#import "UIFont+MaxFontSize.h"
#import "UIView+Frame.h"
#import "UIView+Shake.h"
#import "User.h"
#import "WhatsAppActivity.h"

static CGFloat kScrollMinimumVelocityToToggleTabBar = 180.f;
static NSString * kMatchesHeaderViewFrameChanged = @"kMatchesHeaderViewFrameChanged";

@interface MatchesViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (assign, nonatomic) CGPoint tableViewOffset;
@property (assign, nonatomic) NSInteger numberOfMatches;
@property (copy, nonatomic) NSString *totalProfitText;
@property (strong, nonatomic) NSNumber *totalProfit;
@property (strong, nonatomic) NSIndexPath *totalProfitIndexPath;

- (BetsViewController *)betsViewController;

@end

#pragma mark MatchesViewController

@implementation MatchesViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Match"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"rid" ascending:YES]];
        if (self.championship) {
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"championship = %@", self.championship];
        }
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[FTCoreDataStore mainQueueContext] sectionNameKeyPath:nil cacheName:nil];
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
    if (championship && [championship.slug isEqualToString:self.championship.slug]) {
        return;
    }
    
    _championship = championship;
    self.fetchedResultsController = nil;
    [self.tableView reloadData];
    [self reloadData];
}

- (void)setTotalProfitText:(NSString *)totalProfitText {
    if ([totalProfitText isEqualToString:self.totalProfitText]) {
        return;
    }
    
    _totalProfitText = totalProfitText;
    
    if (self.totalProfitText.length > 0) {
        Match *match = [self.fetchedResultsController.fetchedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"finished = %@", @YES]].lastObject;
		self.totalProfitIndexPath = [self.fetchedResultsController indexPathForObject:match];
    } else {
        self.totalProfitIndexPath = nil;
    }
    
    [self.tableView reloadData];
}

#pragma mark - Instance Methods

- (id)init {
    if (self) {
        self.title = NSLocalizedString(@"Matches", @"");
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title image:[UIImage imageNamed:@"tabbar_btn_matches_ainctive"] selectedImage:[UIImage imageNamed:@"tabbar_btn_matches_active"]];
    }
    
    return self;
}

- (IBAction)rechargeWalletAction:(id)sender {
    if (![User currentUser].canRecharge) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Ops", @"") message:NSLocalizedString(@"Cannot update wallet due to wallet balance", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (FBTweakValue(@"UX", @"Profile", @"Transfers", YES)) {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[RechargeViewController new]];
        [self presentViewController:[[FootblPopupViewController alloc] initWithRootViewController:navigationController] animated:YES completion:nil];
        [self setNeedsStatusBarAppearanceUpdate];
        return;
    }

    [[LoadingHelper sharedInstance] showHud];

    [[User currentUser] rechargeWithSuccess:^(id response) {
        [self reloadWallet];
        [self performSelector:@selector(reloadWallet) withObject:nil afterDelay:1];
        [[LoadingHelper sharedInstance] hideHud];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        SPLogError(@"%@", error);
        [[LoadingHelper sharedInstance] hideHud];
        [[ErrorHandler sharedInstance] displayError:error];
    }];
}

- (void)configureCell:(MatchTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Match *match = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    BOOL hideTotalProfit = !(self.totalProfitIndexPath && indexPath.row == self.totalProfitIndexPath.row && indexPath.section == self.totalProfitIndexPath.section);
    cell.totalProfitArrowImageView.hidden = hideTotalProfit;
    cell.totalProfitView.hidden = hideTotalProfit;
    cell.totalProfitLabel.text = self.totalProfitText;
    if (self.totalProfit.floatValue <= 0) {
        cell.totalProfitView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        cell.totalProfitView.layer.borderColor = [[UIColor colorWithWhite:0.8 alpha:1.0] CGColor];
        cell.totalProfitArrowImageView.tintColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    } else {
        cell.totalProfitView.backgroundColor = [UIColor colorWithRed:47./255.f green:204/255.f blue:118/255.f alpha:1.00];
        cell.totalProfitView.layer.borderColor = [[UIColor colorWithRed:19./255.f green:183/255.f blue:93./255.f alpha:1.00] CGColor];
        cell.totalProfitArrowImageView.tintColor = [UIColor colorWithRed:47./255.f green:204/255.f blue:118/255.f alpha:1.00];
    }
    
    __block NSUInteger cancelBlockId;
    __block Bet *bet = match.myBet;
    __weak typeof(MatchTableViewCell *)weakCell = cell;
    [cell setMatch:match bet:bet viewController:self selectionBlock:^(NSInteger index) {
        if (match.isBetSyncing || match.status != MatchStatusWaiting) {
            [weakCell.cardContentView shake];
            return;
        }
        
        bet = match.myBet;
        
        NSInteger currentBet = match.myBetValue.integerValue;
        MatchResult result = match.myBetResult;
        
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
        
        if (match.myBetValue.integerValue < currentBet && ([User currentUser].localFunds.integerValue - 1) < 0) {
            if (!weakCell.isStepperSelected) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Error: insufient funds", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
                [alert show];
            }
            return;
        }
            
        if (match.myBetValue.integerValue < currentBet && [User currentUser].localFunds.integerValue < 1 && weakCell.isStepperSelected) {
            weakCell.stepperUserInteractionEnabled = NO;
        }
        
        if (cancelBlockId) {
            cancel_block(cancelBlockId);
        }
        
        self.betsViewController.panGestureRecognizer.enabled = NO;
        perform_block_after_delay_k(1, &cancelBlockId, ^{
            self.betsViewController.panGestureRecognizer.enabled = YES;
        });
        
        FTOperationErrorBlock failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
            [[ErrorHandler sharedInstance] displayError:error];
            [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] delay:[FootblAppearance speedForAnimation:FootblAnimationDefault] options:UIViewAnimationOptionAllowUserInteraction animations:^{
                [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            } completion:nil];
            [self reloadWallet];
        };
        
        void(^successBlock)() = ^() {
            [self reloadWallet];
        };
		
        if (result == 0) {
            [bet.editableObject deleteWithSuccess:successBlock failure:failure];
        } else if (bet) {
            [bet.editableObject updateWithBid:@(currentBet) result:result success:successBlock failure:failure];
        } else {
            [Bet createWithMatch:match.editableObject bid:@(currentBet) result:result success:successBlock failure:failure];
        }
        
        [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] animations:^{
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
        }];
        
        [self reloadWallet];
    }];
}

- (void)reloadWallet {
    NSArray *labels = @[self.navigationBarTitleView.walletValueLabel, self.navigationBarTitleView.stakeValueLabel, self.navigationBarTitleView.returnValueLabel, self.navigationBarTitleView.profitValueLabel];
    
    if ([User currentUser]) {
        [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] animations:^{
            for (UILabel *label in labels) {
                label.alpha = 1;
            }
        }];
        self.navigationBarTitleView.walletValueLabel.text = @([User currentUser].localFunds.integerValue).limitedWalletStringValue;
        self.navigationBarTitleView.stakeValueLabel.text = @([User currentUser].localStake.integerValue).limitedWalletStringValue;
        self.navigationBarTitleView.returnValueLabel.text = [User currentUser].toReturnString;
        self.navigationBarTitleView.profitValueLabel.text = [User currentUser].profitString;
    } else {
        for (UILabel *label in labels) {
            label.text = @"";
            label.alpha = 0;
        }
    }
    
    if ([User currentUser].canRecharge) {
        UIImage *rechargeImage = [UIImage imageNamed:@"btn_recharge_money"];
        if ([self.navigationBarTitleView.moneyButton imageForState:UIControlStateNormal] != rechargeImage) {
            [self.navigationBarTitleView.moneyButton setImage:rechargeImage forState:UIControlStateNormal];
        }
    } else {
        [self.navigationBarTitleView.moneyButton setImage:[UIImage imageNamed:@"money_sign"] forState:UIControlStateNormal];
    }
    
    [UIFont setMaxFontSizeToFitBoundsInLabels:labels];
}

- (BetsViewController *)betsViewController {
    if ([self.parentViewController isKindOfClass:[BetsViewController class]]) {
        return (BetsViewController *)self.parentViewController;
    }
    
    return nil;
}

- (void)scrollToFirstActiveMatchAnimated:(BOOL)animated {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"finished = NO"];
    Match *match = [self.fetchedResultsController.fetchedObjects filteredArrayUsingPredicate:predicate].lastObject;
    if (!match) {
        match = self.fetchedResultsController.fetchedObjects.firstObject;
    }
    
    [self.tableView scrollToRowAtIndexPath:[self.fetchedResultsController indexPathForObject:match] atScrollPosition:UITableViewScrollPositionTop animated:animated];
}

- (void)reloadData {
    [super reloadData];
    
    if (!self.championship) {
        self.headerLabel.text = @"";
        return;
    }
    
    if (![FTAuthenticationManager sharedManager].isAuthenticated) {
        return;
    }
    
    self.headerLabel.text = self.championship.displayName;
    NSInteger matches = self.fetchedResultsController.fetchedObjects.count;

    self.numberOfMatches = matches;
    if (matches == 0) {
        [[LoadingHelper sharedInstance] showHud];
    }
    
    NSArray *finishedMatches = [[self.fetchedResultsController.fetchedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"finished = %@", @YES]] valueForKeyPath:@"rid"];
    
    FTOperationErrorBlock failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.refreshControl endRefreshing];
        [[LoadingHelper sharedInstance] hideHud];
        [[ErrorHandler sharedInstance] displayError:error];
    };
    
    [[User currentUser].editableObject getWithSuccess:^(User *user) {
        [self reloadWallet];
        [Match getWithObject:self.championship.editableObject success:^(id response) {
            [self.refreshControl endRefreshing];
            [[LoadingHelper sharedInstance] hideHud];
            [self reloadWallet];
            
            void(^computeProfit)() = ^() {
                NSArray *updatedMatches = [self.fetchedResultsController.fetchedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NONE %@ IN rid AND finished = %@", finishedMatches, @YES]];
                float sum = 0;
                for (NSNumber *betProfit in [updatedMatches valueForKey:@"myBetProfit"]) {
                    sum += [betProfit floatValue];
                }
				NSNumber *numberOfMatches = @(updatedMatches.count);
                
                if (updatedMatches.count > 0 && matches > 0 && FBTweakValue(@"UI", @"Match", @"Profit notification", FT_ENABLE_PROFIT_NOTIFICATION)) {
					NSString *text = nil;
                    if (sum >= 0) {
						 text = [NSString localizedStringWithFormat:NSLocalizedString(@"You made $%lu in the last %@ matches =)", @"{money} {number of matches}"), (long)sum, numberOfMatches];
                    } else {
						text = [NSString localizedStringWithFormat:NSLocalizedString(@"You lost $%lu in the last %@ matches =(", @"{money} {number of matches}"), (long)fabsf(sum), numberOfMatches];
                    }
                    self.totalProfitText = text;
                    self.totalProfit = @(sum);
                }
            };
            
            computeProfit();
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (float)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), computeProfit);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (float)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), computeProfit);
        } failure:failure];
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
    
    CGFloat velocityY = [scrollView.panGestureRecognizer velocityInView:self.view].y;
    
    if (velocityY < -kScrollMinimumVelocityToToggleTabBar) {
        [tabBarController setTabBarHidden:YES animated:YES];
        [self.navigationBarTitleView setTitleHidden:YES animated:YES];
    } else if (velocityY > kScrollMinimumVelocityToToggleTabBar) {
        [tabBarController setTabBarHidden:NO animated:YES];
        [self.navigationBarTitleView setTitleHidden:NO animated:YES];
    }
    
    [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] animations:^{
        self.headerView.frameY = self.navigationBarTitleView.titleHidden ? 64 : 80;
    } completion:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMatchesHeaderViewFrameChanged object:@(self.headerView.frameY) userInfo:nil];
    }];
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
    CGFloat height = 340;
    if (match.elapsed || match.finishedValue) {
        height = 363;
    }
    
    if (self.totalProfitIndexPath && indexPath.row == self.totalProfitIndexPath.row && indexPath.section == self.totalProfitIndexPath.section) {
        height += 56;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIScrollView delegate

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    FootblTabBarController *tabBarController = (FootblTabBarController *)self.tabBarController;
    [tabBarController setTabBarHidden:NO animated:YES];
    [self.navigationBarTitleView setTitleHidden:NO animated:YES];
    if (FBTweakValue(@"UX", @"Match", @"Tap status bar to act. match", FT_ENABLE_TAP_STATUS_BAR)) {
        [self scrollToFirstActiveMatchAnimated:YES];
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - View Lifecycle

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    if (self.presentedViewController && !self.presentedViewController.isBeingDismissed) {
        return self.presentedViewController;
    }
    
    return nil;
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.numberOfMatches = self.fetchedResultsController.fetchedObjects.count;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMatchesHeaderViewFrameChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        self.headerView.frameY = [[note object] floatValue];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    tableViewController.refreshControl = self.refreshControl;
    
    self.tableView = tableViewController.tableView;
    self.tableView.frame = CGRectMake(0, 30, self.view.frameWidth, self.view.frameHeight - 30);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(CGRectGetHeight(self.navigationBarTitleView.frame), 0, 0, 0);
    self.tableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.navigationBarTitleView.frame), 0, 0, 0);
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 15)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 5 + CGRectGetHeight(self.tabBarController.tabBar.frame))];
    [self.tableView registerClass:[MatchTableViewCell class] forCellReuseIdentifier:@"MatchCell"];
    [self.view addSubview:self.tableView];
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, self.tableView.frameWidth, 30)];
    self.headerView.backgroundColor = [FootblAppearance colorForView:FootblColorNavigationBar];
    self.headerView.autoresizesSubviews = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.headerView];
    
    self.headerLabel = [[UILabel alloc] initWithFrame:self.headerView.bounds];
    self.headerLabel.font = [UIFont fontWithName:kFontNameMedium size:12];
    self.headerLabel.textColor = [UIColor colorWithRed:0.00/255.f green:169/255.f blue:72./255.f alpha:1.00];
    self.headerLabel.textAlignment = NSTextAlignmentCenter;
    [self.headerView addSubview:self.headerLabel];
    
    self.headerSliderBackImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider_tab_back"]];
    self.headerSliderBackImageView.center = CGPointMake(15, self.headerLabel.center.y);
    [self.headerView addSubview:self.headerSliderBackImageView];
    
    self.headerSliderForwardImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider_tab_forward"]];
    self.headerSliderForwardImageView.center = CGPointMake(self.headerView.frameWidth - 15, self.headerLabel.center.y);
    [self.headerView addSubview:self.headerSliderForwardImageView];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 29.5, self.headerView.frameWidth, 0.5)];
    separatorView.backgroundColor = [FootblAppearance colorForView:FootblColorNavigationBarSeparator];
    [self.headerView addSubview:separatorView];
    
    [self reloadWallet];
    [self reloadData];
    
    [self scrollToFirstActiveMatchAnimated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadWallet];
    [self.tableView reloadData];
    
    self.headerView.frameY = self.navigationBarTitleView.titleHidden ? 60 : 80;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.totalProfitText = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reloadWallet];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
