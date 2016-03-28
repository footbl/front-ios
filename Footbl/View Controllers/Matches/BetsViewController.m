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

@property (nonatomic, strong) NSMutableArray *championshipViewControllers;

@end

static NSString * const kPrizeLatestFetch = @"kPrizeLatestFetch";
static NSUInteger kPrizeFetchInterval = 60 * 5;

#pragma mark BetsViewController

@implementation BetsViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (id)init {
	self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Matches", @"");
        
        UIImage *image = [UIImage imageNamed:@"tabbar-matches"];
        UIImage *selectedImage = [UIImage imageNamed:@"tabbar-matches-selected"];
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title image:image selectedImage:selectedImage];
        
        self.championshipViewControllers = [[NSMutableArray alloc] init];
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
    for (MatchesViewController *matchesViewController in self.pageViewController.viewControllers) {
        if ([matchesViewController respondsToSelector:@selector(updateInterval)]) {
            interval = MIN(interval, [matchesViewController updateInterval]);
        }
    }
    
    return 60;
}

- (MatchesViewController *)matchesViewControllerAtIndex:(NSInteger)index {
    FTBChampionship *championship = self.championships[index];
    for (MatchesViewController *viewController in self.championshipViewControllers) {
        if ([viewController.championship isEqual:championship]) {
            return viewController;
        }
    }
    
    MatchesViewController *viewController = [[MatchesViewController alloc] init];
    viewController.championship = championship;
    viewController.navigationBarTitleView = self.navigationBarTitleView;
    viewController.betsViewController = self;
    [self.championshipViewControllers addObject:viewController];
    
    return viewController;
}

- (void)reloadScrollView {
    if (self.pageViewController.viewControllers.count == 0) {
        MatchesViewController *viewController = [self matchesViewControllerAtIndex:0];
        if (viewController) {
            [self.pageViewController setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            [self updateHeaderViewWithViewController:viewController];
        }
    }
    
    for (MatchesViewController *matchesViewController in self.pageViewController.viewControllers) {
        if ([matchesViewController respondsToSelector:@selector(reloadData)]) {
            [matchesViewController reloadData];
        }
    }
    
    self.placeholderLabel.hidden = (self.championships.count > 0);
}

- (void)reloadData {
    [super reloadData];
    
    [self reloadWallet];

    if (![[FTBClient client] isAuthenticated]) {
        return;
    }
	
    __weak typeof(self) weakSelf = self;
    [[FTBClient client] championships:0 success:^(NSArray<FTBChampionship *> *object) {
		weakSelf.championships = object;
        
		[weakSelf reloadScrollView];
		
        if (FBTweakValue(@"UX", @"Wallet", @"Recharge Tip", YES) && [RechargeTipPopupViewController shouldBePresented]) {
            RechargeTipPopupViewController *rechargeTipPopup = [[RechargeTipPopupViewController alloc] init];
            rechargeTipPopup.selectionBlock = ^{
                [weakSelf rechargeWalletAction:nil];
            };
            
            FootblPopupViewController *popupViewController = [[FootblPopupViewController alloc] initWithRootViewController:rechargeTipPopup];
            [weakSelf presentViewController:popupViewController animated:YES completion:nil];
            [weakSelf setNeedsStatusBarAppearanceUpdate];
        }
    } failure:^(NSError *error) {
		[[ErrorHandler sharedInstance] displayError:error];
	}];
}

- (void)reloadWallet {
	FTBUser *user = [FTBUser currentUser];
    NSArray *labels = @[self.navigationBarTitleView.walletValueLabel, self.navigationBarTitleView.stakeValueLabel, self.navigationBarTitleView.returnValueLabel, self.navigationBarTitleView.profitValueLabel];
	
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

- (void)updateHeaderViewWithViewController:(MatchesViewController *)viewController {
    self.navigationBarTitleView.headerSliderBackImageView.hidden = [viewController.championship isEqual:self.championships.firstObject];
    self.navigationBarTitleView.headerSliderForwardImageView.hidden = [viewController.championship isEqual:self.championships.lastObject];
    self.navigationBarTitleView.headerLabel.text = viewController.championship.name;
}

#pragma mark - Delegates & Data sources

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(MatchesViewController *)viewController {
    NSInteger index = [self.championshipViewControllers indexOfObject:viewController] - 1;
    if (index >= 0 && index < self.championships.count) {
        return [self matchesViewControllerAtIndex:index];
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(MatchesViewController *)viewController {
    NSInteger index = [self.championshipViewControllers indexOfObject:viewController] + 1;
    if (index >= 0 && index < self.championships.count) {
        return [self matchesViewControllerAtIndex:index];
    }
    
    return nil;
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(nonnull NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    for (MatchesViewController *viewController in self.championshipViewControllers) {
        viewController.tableView.scrollsToTop = [pageViewController.viewControllers containsObject:viewController];
    }
    
    MatchesViewController *viewController = pageViewController.viewControllers.firstObject;
    [self updateHeaderViewWithViewController:viewController];
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor ftb_viewMatchBackgroundColor];
    self.navigationController.navigationBarHidden = YES;
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    
    self.navigationBarTitleView = [[MatchesNavigationBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 110)];
    self.navigationBarTitleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIButton *button = [[UIButton alloc] initWithFrame:self.navigationBarTitleView.moneyButton.frame];
    [button addTarget:self action:@selector(rechargeWalletAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarTitleView.moneyButton.superview addSubview:button];
    [self.view addSubview:self.navigationBarTitleView];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kFTNotificationAuthenticationChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kFTNotificationAuthenticationChanged];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kMatchesNavigationBarTitleAnimateKey];
}

@end
