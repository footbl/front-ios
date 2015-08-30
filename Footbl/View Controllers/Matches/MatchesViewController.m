//
//  MatchesViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/27/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <SPHipster/SPHipster.h>
#import "BetsViewController.h"
#import "FootblPopupViewController.h"
#import "FootblTabBarController.h"
#import "FTAuthenticationManager.h"
#import "LoadingHelper.h"
#import "MatchTableViewCell+Setup.h"
#import "MatchesNavigationBarView.h"
#import "MatchesViewController.h"
#import "NSNumber+Formatter.h"
#import "RechargeButton.h"
#import "RechargeViewController.h"
#import "UIFont+MaxFontSize.h"
#import "UIView+Frame.h"
#import "UIView+Shake.h"
#import "WhatsAppActivity.h"

#import "FTBClient.h"
#import "FTBChampionship.h"
#import "FTBMatch.h"
#import "FTBUser.h"
#import "FTBBet.h"

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

- (void)setChampionship:(FTBChampionship *)championship {
    if (championship && [championship isEqual:self.championship]) {
        return;
    }
    
    _championship = championship;
    self.matches = nil;
    [self.tableView reloadData];
    [self reloadData];
}

- (void)setTotalProfitText:(NSString *)totalProfitText {
    if ([totalProfitText isEqualToString:self.totalProfitText]) {
        return;
    }
    
    _totalProfitText = totalProfitText;
    
    if (self.totalProfitText.length > 0) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"finished = %@", @YES];
        FTBMatch *match = [self.matches filteredArrayUsingPredicate:predicate].firstObject;
		NSUInteger row = [self.matches indexOfObject:match];
		self.totalProfitIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
    } else {
        self.totalProfitIndexPath = nil;
    }
    
    [self.tableView reloadData];
}

#pragma mark - Instance Methods

- (id)init {
	self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Matches", @"");
		UIImage *image = [UIImage imageNamed:@"tabbar_btn_matches_ainctive"];
		UIImage *selectedImage = [UIImage imageNamed:@"tabbar_btn_matches_active"];
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title image:image selectedImage:selectedImage];
    }
    return self;
}

- (IBAction)rechargeWalletAction:(id)sender {
	FTBUser *user = [[FTAuthenticationManager sharedManager] user];
    if (!user.canRecharge) {
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

    [[FTBClient client] rechargeUser:user.identifier success:^(id object) {
        [self reloadWallet];
        [self performSelector:@selector(reloadWallet) withObject:nil afterDelay:1];
        [[LoadingHelper sharedInstance] hideHud];
    } failure:^(NSError *error) {
        SPLogError(@"%@", error);
        [[LoadingHelper sharedInstance] hideHud];
        [[ErrorHandler sharedInstance] displayError:error];
    }];
}

- (void)configureCell:(MatchTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	FTBMatch *match = self.matches[indexPath.row];
	__block NSUInteger cancelBlockId;
	__block FTBBet *bet = match.myBet;
    __weak typeof(MatchTableViewCell *)weakCell = cell;
    [cell setMatch:match bet:bet viewController:self selectionBlock:^(NSInteger index) {
        if (match.isBetSyncing || match.status != FTBMatchStatusWaiting) {
            [weakCell.cardContentView shake];
            return;
        }
        
        bet = match.myBet;
		NSUInteger firstBetValue = MAX(floor((bet.user.fundsValue + bet.user.stakeValue) / 100), 1);
        NSInteger currentBet = match.myBetValue.integerValue;
        FTBMatchResult result = match.myBetResult;
        
        switch (index) {
            case 0: // Host
                if (result == FTBMatchResultHost) {
                    currentBet ++;
                } else if (currentBet == 0) {
                    currentBet = firstBetValue;
                    result = FTBMatchResultHost;
				} else if (currentBet == firstBetValue) {
					currentBet = 0;
				} else {
                    currentBet --;
                }
                break;
            case 1: // Draw
                if (result == FTBMatchResultDraw) {
                    currentBet ++;
                } else if (currentBet == 0) {
                    currentBet = firstBetValue;
                    result = FTBMatchResultDraw;
				} else if (currentBet == firstBetValue) {
					currentBet = 0;
				} else {
                    currentBet --;
                }
                break;
            case 2: // Guest
                if (result == FTBMatchResultGuest) {
                    currentBet ++;
                } else if (currentBet == 0) {
                    currentBet = firstBetValue;
                    result = FTBMatchResultGuest;
				} else if (currentBet == firstBetValue) {
					currentBet = 0;
                } else {
                    currentBet --;
                }
                break;
        }
        if (currentBet == 0) {
            result = 0;
        }
		
		FTBUser *user = [[FTAuthenticationManager sharedManager] user];
        if (match.myBetValue.integerValue < currentBet && (user.localFunds.integerValue - 1) < 0) {
            if (!weakCell.isStepperSelected) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Error: insufient funds", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
                [alert show];
            }
            return;
        }
            
        if (match.myBetValue.integerValue < currentBet && user.localFunds.integerValue < 1 && weakCell.isStepperSelected) {
            weakCell.stepperUserInteractionEnabled = NO;
        }
        
        if (cancelBlockId) {
            cancel_block(cancelBlockId);
        }
        
        self.betsViewController.panGestureRecognizer.enabled = NO;
        perform_block_after_delay_k(1, &cancelBlockId, ^{
            self.betsViewController.panGestureRecognizer.enabled = YES;
        });
        
        FTBBlockError failure = ^(NSError *error) {
            [[ErrorHandler sharedInstance] displayError:error];
            [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] delay:[FootblAppearance speedForAnimation:FootblAnimationDefault] options:UIViewAnimationOptionAllowUserInteraction animations:^{
                [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            } completion:nil];
            [self reloadWallet];
        };
        
        void(^successBlock)() = ^() {
            [self reloadWallet];
        };
		
        if (result == 0 || bet) {
			[[FTBClient client] updateBet:bet user:user success:successBlock failure:failure];
        } else {
			NSString *resultString = nil;
			[[FTBClient client] betInMatch:match.identifier bid:@(currentBet) result:resultString user:user success:successBlock failure:failure];
        }
        
        [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] animations:^{
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
        }];
        
        [self reloadWallet];
    }];
}

- (void)reloadWallet {
    NSArray *labels = @[self.navigationBarTitleView.walletValueLabel, self.navigationBarTitleView.stakeValueLabel, self.navigationBarTitleView.returnValueLabel, self.navigationBarTitleView.profitValueLabel];
	
	FTBUser *user = [[FTAuthenticationManager sharedManager] user];
    if (user) {
        [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] animations:^{
            for (UILabel *label in labels) {
                label.alpha = 1;
            }
        }];
        self.navigationBarTitleView.walletValueLabel.text = @(user.fundsValue).limitedWalletStringValue;
        self.navigationBarTitleView.stakeValueLabel.text = @(user.stakeValue).limitedWalletStringValue;
        self.navigationBarTitleView.returnValueLabel.text = user.toReturnString;
        self.navigationBarTitleView.profitValueLabel.text = user.profitString;
    } else {
        for (UILabel *label in labels) {
            label.text = @"";
            label.alpha = 0;
        }
    }
    
    if (user.canRecharge) {
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
	FTBMatch *match = [self.matches filteredArrayUsingPredicate:predicate].lastObject;
    if (!match) {
        match = self.matches.firstObject;
    }
	
	NSInteger row = [self.matches indexOfObject:match];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
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
    
    self.headerLabel.text = self.championship.name;
    NSInteger matches = self.matches.count;

    self.numberOfMatches = matches;
    if (matches == 0) {
        [[LoadingHelper sharedInstance] showHud];
    }
	
    FTBBlockError failure = ^(NSError *error) {
        [self.refreshControl endRefreshing];
        [[LoadingHelper sharedInstance] hideHud];
        [[ErrorHandler sharedInstance] displayError:error];
    };
	
	[[FTBClient client] user:@"me" success:^(FTBUser *user) {
        [self reloadWallet];
		
		[[FTBClient client] matchesInChampionship:self.championship page:0 success:^(id object) {
            [self.refreshControl endRefreshing];
            [[LoadingHelper sharedInstance] hideHud];
            [self reloadWallet];
            
            void(^computeProfit)() = ^() {
				NSTimeInterval weekInterval = -604800;
				NSDate *week = [NSDate dateWithTimeIntervalSinceNow:weekInterval];
				NSPredicate *predicate = [NSPredicate predicateWithFormat:@"finished = YES AND date >= %@", week];
                NSArray *updatedMatches = [self.matches filteredArrayUsingPredicate:predicate];
                float sum = 0;
                for (NSNumber *betProfit in [updatedMatches valueForKey:@"myBetProfit"]) {
                    sum += [betProfit floatValue];
                }
				NSNumber *numberOfMatches = @(updatedMatches.count);
                
                if (updatedMatches.count > 0 && matches > 0 && FBTweakValue(@"UI", @"Match", @"Profit notification", FT_ENABLE_PROFIT_NOTIFICATION)) {
					NSString *text = nil;
                    if (sum >= 0) {
						NSString *format = NSLocalizedString(@"You made $%lu in the last %@ matches =)", @"{money} {number of matches}");
						text = [NSString localizedStringWithFormat:format, (long)sum, numberOfMatches];
                    } else {
						NSString *format = NSLocalizedString(@"You lost $%lu in the last %@ matches =(", @"{money} {number of matches}");
						text = [NSString localizedStringWithFormat:format, (long)fabsf(sum), numberOfMatches];
                    }
                    self.totalProfitText = text;
                    self.totalProfit = @(sum);
					self.totalProfitLabel.text = self.totalProfitText;
					if (self.totalProfit.floatValue <= 0) {
						self.totalProfitBoxView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];
						self.totalProfitBoxView.layer.borderColor = [[UIColor colorWithWhite:0.8 alpha:1.0] CGColor];
						self.totalProfitArrowImageView.tintColor = [UIColor colorWithWhite:0.7 alpha:1.0];
					} else {
						self.totalProfitBoxView.backgroundColor = [UIColor colorWithRed:47./255.f green:204/255.f blue:118/255.f alpha:1.00];
						self.totalProfitBoxView.layer.borderColor = [[UIColor colorWithRed:19./255.f green:183/255.f blue:93./255.f alpha:1.00] CGColor];
						self.totalProfitArrowImageView.tintColor = [UIColor colorWithRed:47./255.f green:204/255.f blue:118/255.f alpha:1.00];
					}
                }
            };
            
            computeProfit();
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (float)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), computeProfit);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (float)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), computeProfit);
        } failure:failure];
    } failure:failure];
}

- (NSTimeInterval)updateInterval {
    FTBMatch *match = [self.matches filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"finished = %@", @NO]].lastObject;
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
        self.headerView.y = self.navigationBarTitleView.titleHidden ? 64 : 80;
    } completion:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMatchesHeaderViewFrameChanged object:@(self.headerView.y) userInfo:nil];
    }];
}

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.matches.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MatchTableViewCell *cell = (MatchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MatchCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FTBMatch *match = self.matches[indexPath.row];
    CGFloat height = 340;
    if (match.elapsed || match.isFinished) {
        height = 363;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return FLT_EPSILON;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (self.totalProfitIndexPath && self.totalProfitIndexPath.section == section) ? self.totalProfitView.height : FLT_EPSILON;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (self.totalProfitIndexPath && self.totalProfitIndexPath.section == section) ? self.totalProfitView : nil;
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
    
    self.numberOfMatches = self.matches.count;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMatchesHeaderViewFrameChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        self.headerView.y = [[note object] floatValue];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    tableViewController.refreshControl = self.refreshControl;
	
    self.tableView = tableViewController.tableView;
    self.tableView.frame = CGRectMake(0, 30, self.view.width, self.view.height - 30);
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
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, self.tableView.width, 30)];
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
    self.headerSliderForwardImageView.center = CGPointMake(self.headerView.width - 15, self.headerLabel.center.y);
    [self.headerView addSubview:self.headerSliderForwardImageView];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 29.5, self.headerView.width, 0.5)];
    separatorView.backgroundColor = [FootblAppearance colorForView:FootblColorNavigationBarSeparator];
    [self.headerView addSubview:separatorView];
	
	UIImage *totalProfitArrowImage = [[UIImage imageNamed:@"arrow-down"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	self.totalProfitView = [[UIView alloc] initWithFrame:CGRectMake(-1, 0, self.tableView.width + 2, 33 + totalProfitArrowImage.size.height)];
	
	self.totalProfitBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.totalProfitView.width, 33)];
	self.totalProfitBoxView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.totalProfitBoxView.backgroundColor = [UIColor colorWithRed:47./255.f green:204/255.f blue:118/255.f alpha:1.00];
	self.totalProfitBoxView.clipsToBounds = NO;
	self.totalProfitBoxView.layer.borderColor = [[UIColor colorWithRed:19./255.f green:183/255.f blue:93./255.f alpha:1.00] CGColor];
	self.totalProfitBoxView.layer.borderWidth = 0.5;
	[self.totalProfitView addSubview:self.totalProfitBoxView];
	
	self.totalProfitArrowImageView = [[UIImageView alloc] initWithImage:totalProfitArrowImage];
	self.totalProfitArrowImageView.center = CGPointMake(self.totalProfitView.midX, self.totalProfitBoxView.maxY + (self.totalProfitArrowImageView.image.size.height / 2) - 0.5);
	self.totalProfitArrowImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[self.totalProfitView addSubview:self.totalProfitArrowImageView];
	
	self.totalProfitLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.totalProfitView.width - 20, self.totalProfitBoxView.height)];
	self.totalProfitLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.totalProfitLabel.textColor = [UIColor whiteColor];
	self.totalProfitLabel.textAlignment = NSTextAlignmentCenter;
	self.totalProfitLabel.font = [UIFont fontWithName:kFontNameMedium size:13];
	self.totalProfitLabel.adjustsFontSizeToFitWidth = YES;
	self.totalProfitLabel.minimumScaleFactor = 0.6;
	[self.totalProfitView addSubview:self.totalProfitLabel];
    
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
    
    self.headerView.y = self.navigationBarTitleView.titleHidden ? 60 : 80;
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
