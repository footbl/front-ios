//
//  BetsViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/10/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <SPHipster/SPHipster.h>
#import "BetsViewController.h"
#import "DailyBonusPopupViewController.h"
#import "FootblPopupAnimatedTransition.h"
#import "LoadingHelper.h"
#import "MatchesNavigationBarView.h"
#import "MatchesViewController.h"
#import "NSDate+Utils.h"
#import "NSNumber+Formatter.h"
#import "RechargeButton.h"
#import "RechargeTipPopupViewController.h"
#import "RechargeViewController.h"
#import "UIFont+MaxFontSize.h"
#import "UILabel+MaxFontSize.h"
#import "UIView+Frame.h"

#import "FTBClient.h"
#import "FTBChampionship.h"
#import "FTBMatch.h"
#import "FTBUser.h"
#import "FTBPrize.h"

@interface BetsViewController ()

@property (strong, nonatomic) NSMutableDictionary *championshipsViewControllers;
@property (assign, nonatomic) NSInteger scrollViewCurrentPage;
@property (assign, nonatomic) NSInteger scrollViewLength;

@end

static NSString * const kPrizeLatestFetch = @"kPrizeLatestFetch";
static NSUInteger kPrizeFetchInterval = 60 * 5;

#pragma mark BetsViewController

@implementation BetsViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (void)setScrollViewCurrentPage:(NSInteger)scrollViewCurrentPage {
    _scrollViewCurrentPage = scrollViewCurrentPage;

    for (MatchesViewController *matchesViewController in self.championshipsViewControllers.allValues) {
        if ([matchesViewController respondsToSelector:@selector(tableView)]) {
            matchesViewController.tableView.scrollsToTop = NO;
        }
    }
    
    if (self.championships.count >= self.scrollViewCurrentPage + 1) {
        FTBChampionship *championship = self.championships[self.scrollViewCurrentPage];
        MatchesViewController *matchesViewController = self.championshipsViewControllers[championship.identifier];
        matchesViewController.tableView.scrollsToTop = YES;
    }
}

#pragma mark - Instance Methods

- (id)init {
	self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Matches", @"");
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title image:[UIImage imageNamed:@"tabbar_btn_matches_ainctive"] selectedImage:[UIImage imageNamed:@"tabbar_btn_matches_active"]];
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

- (NSTimeInterval)updateInterval {
    NSTimeInterval interval = [super updateInterval];
    for (MatchesViewController *matchesViewController in self.championshipsViewControllers.allValues) {
        if ([matchesViewController respondsToSelector:@selector(updateInterval)]) {
            interval = MIN(interval, [matchesViewController updateInterval]);
        }
    }
    
    return 60;
}

- (void)reloadScrollView {
    NSMutableDictionary *championshipsToRemove = self.championshipsViewControllers.mutableCopy;
    self.scrollViewLength = 0;
    NSArray *championships = self.championships;
    CGSize contentSize = self.scrollView.frame.size;
    
    for (FTBChampionship *championship in championships) {
        MatchesViewController *matchesViewController = self.championshipsViewControllers[championship.identifier];
        if (!matchesViewController) {
            matchesViewController = [MatchesViewController new];
            matchesViewController.championship = championship;
            matchesViewController.navigationBarTitleView = self.navigationBarTitleView;
            matchesViewController.tableView.scrollsToTop = NO;
            [self addChildViewController:matchesViewController];
            [self.scrollView addSubview:matchesViewController.view];
            self.championshipsViewControllers[championship.identifier] = matchesViewController;
        }
        
        matchesViewController.headerSliderBackImageView.hidden = NO;
        matchesViewController.headerSliderForwardImageView.hidden = NO;
        
        if (self.scrollViewLength == 0) {
            matchesViewController.headerSliderBackImageView.hidden = YES;
        }
        
        matchesViewController.view.frame = CGRectMake(self.scrollView.width * self.scrollViewLength, 0, self.scrollView.width, self.scrollView.height);
        contentSize = CGSizeMake(CGRectGetMaxX(matchesViewController.view.frame), self.scrollView.height);
        [championshipsToRemove removeObjectForKey:championship.identifier];
        self.scrollViewLength++;
    }
    
    self.scrollView.contentSize = contentSize;
    
    if (championships.count == 0) {
        self.placeholderLabel.hidden = NO;
    } else {
        self.placeholderLabel.hidden = YES;
    }
    
    [self.championshipsViewControllers removeObjectsForKeys:championshipsToRemove.allKeys];
    for (UIViewController *viewController in championshipsToRemove.allValues) {
        [viewController removeFromParentViewController];
        [viewController.view removeFromSuperview];
    }
}

- (void)reloadData {
    [super reloadData];
    
    [self reloadWallet];

    if (![[FTBClient client] isAuthenticated]) {
        return;
    }
	
    [[FTBClient client] championships:0 success:^(NSArray<FTBChampionship *> *object) {
		self.championships = object;
		[self reloadScrollView];
		
        if (FBTweakValue(@"UX", @"Wallet", @"Recharge Tip", YES) && [RechargeTipPopupViewController shouldBePresented]) {
            RechargeTipPopupViewController *rechargeTipPopup = [RechargeTipPopupViewController new];
            rechargeTipPopup.selectionBlock = ^{
                [self rechargeWalletAction:nil];
            };
            FootblPopupViewController *popupViewController = [[FootblPopupViewController alloc] initWithRootViewController:rechargeTipPopup];
            [self presentViewController:popupViewController animated:YES completion:nil];
            [self setNeedsStatusBarAppearanceUpdate];
        }
		
		for (MatchesViewController *matchesViewController in self.championshipsViewControllers.allValues) {
			if ([matchesViewController respondsToSelector:@selector(reloadData)]) {
				[matchesViewController reloadData];
			}
		}
    } failure:^(NSError *error) {
		[[ErrorHandler sharedInstance] displayError:error];
	}];
}

- (void)reloadWallet {
	FTBUser *user = [FTBUser currentUser];
    for (FTBMatch *match in user.pendingMatchesToSyncBet) {
        if (match.isBetSyncing) {
            return;
        }
    }
    
    NSArray *labels = @[self.navigationBarTitleView.walletValueLabel, self.navigationBarTitleView.stakeValueLabel, self.navigationBarTitleView.returnValueLabel, self.navigationBarTitleView.profitValueLabel];
	
    if (user) {
        [UIView animateWithDuration:FTBAnimationDuration animations:^{
            for (UILabel *label in labels) {
                label.alpha = 1;
            }
        }];
        self.navigationBarTitleView.walletValueLabel.text = @(user.localFunds.integerValue).limitedWalletStringValue;
        self.navigationBarTitleView.stakeValueLabel.text = @(user.localStake.integerValue).limitedWalletStringValue;
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

#pragma mark - Delegates & Data sources

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor ftb_viewMatchBackgroundColor];
    self.navigationController.navigationBarHidden = YES;
    self.championshipsViewControllers = [NSMutableDictionary new];
    
    self.navigationBarTitleView = [[MatchesNavigationBarView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 80)];
    self.navigationBarTitleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIButton *button = [[UIButton alloc] initWithFrame:self.navigationBarTitleView.moneyButton.frame];
    [button addTarget:self action:@selector(rechargeWalletAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarTitleView.moneyButton.superview addSubview:button];
    [self.view addSubview:self.navigationBarTitleView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollsToTop = NO;
    [self.view insertSubview:self.scrollView belowSubview:self.navigationBarTitleView];
    
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, self.view.width - 40, 200)];
    self.placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.placeholderLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:15];
    self.placeholderLabel.textColor = [UIColor colorWithRed:156/255.f green:164/255.f blue:158/255.f alpha:1.00];
    self.placeholderLabel.textAlignment = NSTextAlignmentCenter;
    self.placeholderLabel.text = NSLocalizedString(@"Leagues placeholder", @"");
    self.placeholderLabel.hidden = YES;
    self.placeholderLabel.numberOfLines = 0;
    [self.view addSubview:self.placeholderLabel];
    
    [self reloadData];
    
    self.scrollViewCurrentPage = 0;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kFTNotificationAuthenticationChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.scrollViewCurrentPage = self.scrollViewCurrentPage;
    [self reloadWallet];
	
	FTBUser *user = [FTBUser currentUser];
    if (FBTweakValue(@"UX", @"Wallet", @"Glowing Button", YES) && user.canRecharge) {
        self.navigationBarTitleView.moneyButton.numberOfAnimations = 3;
        self.navigationBarTitleView.moneyButton.animating = YES;
    }
    
    if (FBTweakValue(@"UX", @"Wallet", @"Daily Bonus", YES) && (![[NSUserDefaults standardUserDefaults] objectForKey:kPrizeLatestFetch] || fabs([[NSDate date] timeIntervalSinceDate:[[NSUserDefaults standardUserDefaults] objectForKey:kPrizeLatestFetch]]) > kPrizeFetchInterval)) {
		[[FTBClient client] prizesForUser:user page:0 unread:YES success:^(NSArray *prizes) {
            [prizes enumerateObjectsUsingBlock:^(FTBPrize *prize, NSUInteger idx, BOOL *stop) {
                if (prize.type == FTBPrizeTypeDaily || prize.type == FTBPrizeTypeUpdate) {
                    *stop = YES;
                    DailyBonusPopupViewController *dailyBonusPopup = [DailyBonusPopupViewController new];
                    dailyBonusPopup.prize = prize;
                    FootblPopupViewController *popupViewController = [[FootblPopupViewController alloc] initWithRootViewController:dailyBonusPopup];
                    [self presentViewController:popupViewController animated:YES completion:nil];
                    [self setNeedsStatusBarAppearanceUpdate];
                }
            }];
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kPrizeLatestFetch];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } failure:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    for (MatchesViewController *matchesViewController in self.championshipsViewControllers.allValues) {
        if ([matchesViewController respondsToSelector:@selector(tableView)]) {
            matchesViewController.tableView.scrollsToTop = NO;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kFTNotificationAuthenticationChanged];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kMatchesNavigationBarTitleAnimateKey];
}

@end
