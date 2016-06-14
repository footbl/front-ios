//
//  MatchesViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/27/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <SPHipster/SPHipster.h>
#import <SVPullToRefresh/SVPullToRefresh.h>

#import "MatchesViewController.h"
#import "BetsViewController.h"
#import "ChallengeViewController.h"
#import "ChampionshipsHeaderView.h"
#import "FootblPopupViewController.h"
#import "FootblTabBarController.h"
#import "FTBBet.h"
#import "FTBChallenge.h"
#import "FTBChampionship.h"
#import "FTBClient.h"
#import "FTBMatch.h"
#import "FTBUser.h"
#import "LoadingHelper.h"
#import "MatchesNavigationBarView.h"
#import "MatchTableViewCell+Setup.h"
#import "NSNumber+Formatter.h"
#import "RechargeButton.h"
#import "RechargeViewController.h"
#import "UIFont+MaxFontSize.h"
#import "UIView+Frame.h"
#import "UIView+Shake.h"
#import "WhatsAppActivity.h"

static CGFloat kScrollMinimumVelocityToToggleTabBar = 180.f;

@interface MatchesViewController ()

@property (nonatomic, strong) UITableViewController *tableViewController;
@property (nonatomic) NSUInteger page;

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
	FTBUser *user = [FTBUser currentUser];
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
	__weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    
    void (^selectionBlock)(NSInteger) = ^(NSInteger index) {
        if (match.isBetSyncing || match.status != FTBMatchStatusWaiting) {
            [weakCell.cardContentView shake];
            return;
        }
        
        FTBUser *user = [FTBUser currentUser];
        NSUInteger firstBetValue = MAX(floor((user.funds.integerValue + user.stake.integerValue) / 100), 1);
        NSInteger currentBet = match.myBet.bid.integerValue;
        FTBMatchResult result = match.myBet.result;
        
        switch (index) {
            case 0: // Host
                if (result == FTBMatchResultHost) {
                    currentBet++;
                } else if (currentBet == 0) {
                    currentBet = firstBetValue;
                    result = FTBMatchResultHost;
                } else if (currentBet == firstBetValue) {
                    currentBet = 0;
                } else {
                    currentBet--;
                }
                break;
            case 1: // Draw
                if (result == FTBMatchResultDraw) {
                    currentBet++;
                } else if (currentBet == 0) {
                    currentBet = firstBetValue;
                    result = FTBMatchResultDraw;
                } else if (currentBet == firstBetValue) {
                    currentBet = 0;
                } else {
                    currentBet--;
                }
                break;
            case 2: // Guest
                if (result == FTBMatchResultGuest) {
                    currentBet++;
                } else if (currentBet == 0) {
                    currentBet = firstBetValue;
                    result = FTBMatchResultGuest;
                } else if (currentBet == firstBetValue) {
                    currentBet = 0;
                } else {
                    currentBet--;
                }
                break;
        }
        
        if (currentBet == 0) {
            result = FTBMatchResultUnknown;
        }
        
        if (match.myBet.bid.integerValue < currentBet && (user.funds.integerValue - 1) < 0) {
            if (!weakCell.isStepperSelected) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Error: insufient funds", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
                [alert show];
            }
            return;
        }
        
        if (match.myBet.bid.integerValue < currentBet && user.funds.integerValue < 1 && weakCell.isStepperSelected) {
            weakCell.stepperUserInteractionEnabled = NO;
        }
        
        if (cancelBlockId) {
            cancel_block(cancelBlockId);
        }
        
        FTBBlockError failureBlock = ^(NSError *error) {
            [[ErrorHandler sharedInstance] displayError:error];
            [UIView animateWithDuration:FTBAnimationDuration delay:FTBAnimationDuration options:UIViewAnimationOptionAllowUserInteraction animations:^{
                [weakSelf configureCell:[weakSelf.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            } completion:nil];
            [weakSelf reloadWallet];
        };
        
        void(^successBlock)() = ^() {
            [weakSelf reloadWallet];
        };
        
        FTBBet *myBet = match.myBet;
        if (myBet && myBet.identifier.length > 0) {
            FTBBet *newBet = [myBet copy];
            newBet.bid = @(currentBet);
            newBet.result = result;
            [[FTBClient client] updateBet:newBet match:match success:successBlock failure:failureBlock];
        } else {
            [[FTBClient client] betInMatch:match bid:@(currentBet) result:result success:successBlock failure:failureBlock];
        }
        
        [UIView animateWithDuration:FTBAnimationDuration animations:^{
            [weakSelf configureCell:[weakSelf.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
        }];
        
        [weakSelf reloadWallet];
    };
    
    if (self.challengedUser) {
        [cell setMatch:match bet:bet viewController:self selectionBlock:nil];
    } else {
        [cell setMatch:match bet:bet viewController:self selectionBlock:selectionBlock];
    }
}

- (void)reloadWallet {
	NSArray *labels = @[self.navigationBarTitleView.walletValueLabel,
                        self.navigationBarTitleView.stakeValueLabel,
                        self.navigationBarTitleView.returnValueLabel,
                        self.navigationBarTitleView.profitValueLabel];
	
	FTBUser *user = [FTBUser currentUser];
	if (user) {
		[UIView animateWithDuration:FTBAnimationDuration animations:^{
			for (UILabel *label in labels) {
				label.alpha = 1;
			}
		}];
		self.navigationBarTitleView.walletValueLabel.text = user.wallet.limitedWalletStringValue;
		self.navigationBarTitleView.stakeValueLabel.text = user.stake.limitedWalletStringValue;
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
	if (self.matches.count == 0) {
		return;
	}
    
    [self updateInsets];
	
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
		return;
	}
	
	if (![[FTBClient client] isAuthenticated]) {
		return;
	}
	
	
	if (self.matches.count == 0) {
		[[LoadingHelper sharedInstance] showHud];
	}
	
	FTBBlockError failure = ^(NSError *error) {
		[self.tableViewController.refreshControl endRefreshing];
		[[LoadingHelper sharedInstance] hideHud];
		[[ErrorHandler sharedInstance] displayError:error];
	};
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        self.page++;
        [[FTBClient client] matchesInChampionship:self.championship page:self.page success:^(NSArray *objects) {
            [self.matches addObjectsFromArray:objects];
            [self.tableView reloadData];
            [self.tableView.infiniteScrollingView stopAnimating];
            self.tableView.showsInfiniteScrolling = (objects.count == FTBClientPageSize);
        } failure:failure];
    }];
	
	FTBUser *me = [FTBUser currentUser];
	[[FTBClient client] user:me.identifier success:^(FTBUser *user) {
		[self reloadWallet];
		
        [[FTBClient client] betsForUser:me match:nil activeOnly:NO page:0 success:^(NSArray *bets) {
            
            self.page = 0;
            self.tableView.showsInfiniteScrolling = YES;
            [[FTBClient client] matchesInChampionship:self.championship page:self.page success:^(NSArray *objects) {
                NSUInteger previousMatchesCount = self.matches.count;
                self.matches = [[NSMutableArray alloc] initWithArray:objects];
                [self.tableView reloadData];
                [self reloadWallet];
                
                if (previousMatchesCount == 0 && objects.count > 0) {
                    [self scrollToFirstActiveMatchAnimated:NO];
                }
                
				[self.tableViewController.refreshControl endRefreshing];
				[[LoadingHelper sharedInstance] hideHud];
			} failure:failure];
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

- (void)updateInsets {
    CGFloat top = self.navigationBarTitleView.championshipsHeaderView.maxY;
    CGFloat bottom = ((FootblTabBarController *)self.tabBarController).isTabBarHidden ? 0 : self.tabBarController.tabBar.height;
    UIEdgeInsets inset = UIEdgeInsetsMake(top, 0, bottom, 0);
    self.tableView.contentInset = inset;
    self.tableView.scrollIndicatorInsets = inset;
}

#pragma mark - Delegates & Data sources

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	FootblTabBarController *tabBarController = (FootblTabBarController *)self.tabBarController;
	
	CGFloat velocityY = [scrollView.panGestureRecognizer velocityInView:self.view].y;
	
    BOOL wasTabBarHidden = tabBarController.isTabBarHidden;
    
	if (velocityY < -kScrollMinimumVelocityToToggleTabBar) {
		[tabBarController setTabBarHidden:YES animated:YES];
		[self.navigationBarTitleView setTitleHidden:YES animated:YES];
	} else if (velocityY > kScrollMinimumVelocityToToggleTabBar) {
		[tabBarController setTabBarHidden:NO animated:YES];
		[self.navigationBarTitleView setTitleHidden:NO animated:YES];
	}
    
    BOOL isTabBarHidden = tabBarController.isTabBarHidden;
	
    if (isTabBarHidden != wasTabBarHidden) {
        [UIView animateWithDuration:FTBAnimationDuration animations:^{
            [self updateInsets];
        }];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    FootblTabBarController *tabBarController = (FootblTabBarController *)self.tabBarController;
    [tabBarController setTabBarHidden:NO animated:YES];
    [self.navigationBarTitleView setTitleHidden:NO animated:YES];
    [self updateInsets];
    return YES;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

    FTBMatch *match = self.matches[indexPath.row];
    if (self.challengedUser && !match.finished && match.elapsed == 0) {
        ChallengeViewController *viewController = [[ChallengeViewController alloc] init];
        viewController.match = match;
        viewController.challengedUser = self.challengedUser;
        [self.navigationController pushViewController:viewController animated:YES];
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
	
	self.view.backgroundColor = [UIColor ftb_viewMatchBackgroundColor];
    self.navigationController.navigationBarHidden = !self.challengedUser;
	
	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
	[refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
	
	self.tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
	self.tableViewController.refreshControl = refreshControl;
    [self addChildViewController:self.tableViewController];
    [self.view addSubview:self.tableViewController.view];
    
	self.tableView = self.tableViewController.tableView;
	self.tableView.frame = self.view.bounds;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.backgroundColor = self.view.backgroundColor;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.tableView registerClass:[MatchTableViewCell class] forCellReuseIdentifier:@"MatchCell"];
	
	[self reloadWallet];
	[self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self reloadWallet];
	[self.tableView reloadData];
	
	[self updateInsets];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self reloadWallet];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
