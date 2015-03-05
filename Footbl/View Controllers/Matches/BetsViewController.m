//
//  BetsViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/10/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SPHipster/SPHipster.h>
#import "BetsViewController.h"
#import "Championship.h"
#import "DailyBonusPopupViewController.h"
#import "FootblPopupAnimatedTransition.h"
#import "FTAuthenticationManager.h"
#import "Entry.h"
#import "LoadingHelper.h"
#import "Match.h"
#import "MatchesNavigationBarView.h"
#import "MatchesViewController.h"
#import "NSDate+Utils.h"
#import "NSNumber+Formatter.h"
#import "Prize.h"
#import "RechargeButton.h"
#import "RechargeTipPopupViewController.h"
#import "RechargeViewController.h"
#import "UIFont+MaxFontSize.h"
#import "UILabel+MaxFontSize.h"
#import "UIView+Frame.h"
#import "User.h"

@interface BetsViewController ()

@property (strong, nonatomic) NSMutableDictionary *championshipsViewControllers;
@property (assign, nonatomic) CGFloat gestureRecognizerInitialPositionX;
@property (assign, nonatomic) NSInteger scrollViewCurrentPage;
@property (assign, nonatomic) NSInteger scrollViewLength;

@end

static NSString * const kManagedLeaguesViewControllerKey = @"kManagedLeaguesViewControllerKey";
static NSString * const kPrizeLatestFetch = @"kPrizeLatestFetch";
static NSUInteger kPrizeFetchInterval = 60 * 5;

#pragma mark BetsViewController

@implementation BetsViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Championship"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"enabled = %@", @YES];
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

- (void)setScrollViewCurrentPage:(NSInteger)scrollViewCurrentPage {
    _scrollViewCurrentPage = scrollViewCurrentPage;

    for (MatchesViewController *matchesViewController in self.championshipsViewControllers.allValues) {
        if ([matchesViewController respondsToSelector:@selector(tableView)]) {
            matchesViewController.tableView.scrollsToTop = NO;
        }
    }
    
    if (self.fetchedResultsController.fetchedObjects.count >= self.scrollViewCurrentPage + 1) {
        Championship *championship = self.fetchedResultsController.fetchedObjects[self.scrollViewCurrentPage];
        MatchesViewController *matchesViewController = self.championshipsViewControllers[championship.slug];
        matchesViewController.tableView.scrollsToTop = YES;
    }
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
    
    [[User currentUser].editableObject rechargeWithSuccess:^(id response) {
        [self reloadWallet];
        [self performSelector:@selector(reloadWallet) withObject:nil afterDelay:1];
        [[LoadingHelper sharedInstance] hideHud];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
    NSArray *championships = self.fetchedResultsController.fetchedObjects;
    CGSize contentSize = self.scrollView.frame.size;
    
    for (Championship *championship in championships) {
        MatchesViewController *matchesViewController = self.championshipsViewControllers[championship.slug];
        if (!matchesViewController) {
            matchesViewController = [MatchesViewController new];
            matchesViewController.championship = championship;
            matchesViewController.navigationBarTitleView = self.navigationBarTitleView;
            matchesViewController.tableView.scrollsToTop = NO;
            [self addChildViewController:matchesViewController];
            [self.scrollView addSubview:matchesViewController.view];
            self.championshipsViewControllers[championship.slug] = matchesViewController;
        }
        
        matchesViewController.headerSliderBackImageView.hidden = NO;
        matchesViewController.headerSliderForwardImageView.hidden = NO;
        
        if (self.scrollViewLength == 0) {
            matchesViewController.headerSliderBackImageView.hidden = YES;
        }
        
        matchesViewController.view.frame = CGRectMake(self.scrollView.width * self.scrollViewLength, 0, self.scrollView.width, self.scrollView.height);
        contentSize = CGSizeMake(CGRectGetMaxX(matchesViewController.view.frame), self.scrollView.height);
        [championshipsToRemove removeObjectForKey:championship.slug];
        self.scrollViewLength ++;
    }
    
    if (self.fetchedResultsController.fetchedObjects.count > 0) {
        UIViewController *managedLeaguesViewController = self.championshipsViewControllers[kManagedLeaguesViewControllerKey];
        if (!managedLeaguesViewController) {
            [self reloadManagedLeaguesViewController];
        }
        
        [championshipsToRemove removeObjectForKey:kManagedLeaguesViewControllerKey];
        managedLeaguesViewController.view.frame = CGRectMake(self.scrollView.width * self.fetchedResultsController.fetchedObjects.count, 0, self.scrollView.width, self.scrollView.height);
        contentSize = CGSizeMake(CGRectGetMaxX(managedLeaguesViewController.view.frame), self.scrollView.height);
        self.scrollViewLength ++;
    }
    
    self.scrollView.contentSize = contentSize;
    self.scrollView.contentOffset = CGPointMake(MIN(MAX(0, contentSize.width - self.scrollView.width), self.scrollView.contentOffset.x), self.scrollView.contentOffset.y);
    
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

    if (![FTAuthenticationManager sharedManager].isAuthenticated) {
        return;
    }
    
    [[User currentUser].editableObject getWithSuccess:^(id response) {
        if (FBTweakValue(@"UX", @"Wallet", @"Recharge Tip", YES) && [RechargeTipPopupViewController shouldBePresented]) {
            RechargeTipPopupViewController *rechargeTipPopup = [RechargeTipPopupViewController new];
            rechargeTipPopup.selectionBlock = ^{
                [self rechargeWalletAction:nil];
            };
            FootblPopupViewController *popupViewController = [[FootblPopupViewController alloc] initWithRootViewController:rechargeTipPopup];
            [self presentViewController:popupViewController animated:YES completion:nil];
            [self setNeedsStatusBarAppearanceUpdate];
        }
    } failure:nil];
    
    [Entry getWithObject:[User currentUser] success:^(id response) {
        for (MatchesViewController *matchesViewController in self.championshipsViewControllers.allValues) {
            if ([matchesViewController respondsToSelector:@selector(reloadData)]) {
                [matchesViewController reloadData];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[ErrorHandler sharedInstance] displayError:error];
    }];
}

- (void)reloadWallet {
    for (Match *match in [User currentUser].pendingMatchesToSyncBet) {
        if (match.isBetSyncing) {
            return;
        }
    }
    
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

- (void)reloadManagedLeaguesViewController {
    UIViewController *managedLeaguesViewController = self.championshipsViewControllers[kManagedLeaguesViewControllerKey];
    [managedLeaguesViewController.view removeFromSuperview];
    [managedLeaguesViewController removeFromParentViewController];
    
    managedLeaguesViewController = [UIViewController new];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.navigationBarTitleView.height, self.view.width, 30)];
    headerView.backgroundColor = [FootblAppearance colorForView:FootblColorNavigationBar];
    headerView.autoresizesSubviews = UIViewAutoresizingFlexibleWidth;
    [managedLeaguesViewController.view addSubview:headerView];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:headerView.bounds];
    headerLabel.font = [UIFont fontWithName:kFontNameMedium size:12];
    headerLabel.textColor = [UIColor colorWithRed:0.00/255.f green:169/255.f blue:72./255.f alpha:1.00];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = NSLocalizedString(@"My Leagues", @"");
    [headerView addSubview:headerLabel];
    
    UIImageView *headerSliderBackImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider_tab_back"]];
    headerSliderBackImageView.center = CGPointMake(15, headerLabel.center.y);
    [headerView addSubview:headerSliderBackImageView];
    
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, self.view.width - 40, 200)];
    placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    placeholderLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:15];
    placeholderLabel.textColor = [UIColor colorWithRed:156/255.f green:164/255.f blue:158/255.f alpha:1.00];
    placeholderLabel.textAlignment = NSTextAlignmentCenter;
    placeholderLabel.text = NSLocalizedString(@"Leagues placeholder", @"");
    placeholderLabel.numberOfLines = 0;
    [managedLeaguesViewController.view addSubview:placeholderLabel];
    
    [self addChildViewController:managedLeaguesViewController];
    [self.scrollView addSubview:managedLeaguesViewController.view];
    self.championshipsViewControllers[kManagedLeaguesViewControllerKey] = managedLeaguesViewController;
    
    managedLeaguesViewController.view.frame = CGRectMake(self.scrollView.width * self.fetchedResultsController.fetchedObjects.count, 0, self.scrollView.width, self.scrollView.height);
    CGSize contentSize = CGSizeMake(CGRectGetMaxX(managedLeaguesViewController.view.frame), self.scrollView.height);

    self.scrollView.contentSize = contentSize;
    self.scrollView.contentOffset = CGPointMake(MIN(MAX(0, contentSize.width - self.scrollView.width), self.scrollView.contentOffset.x), self.scrollView.contentOffset.y);
}

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    CGFloat touchX = [gestureRecognizer locationInView:self.view].x;
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.gestureRecognizerInitialPositionX = touchX;
        case UIGestureRecognizerStateChanged:
            self.scrollView.contentOffset = CGPointMake(MAX(0, MIN(self.scrollViewCurrentPage * self.scrollView.width + self.gestureRecognizerInitialPositionX - touchX, self.scrollView.contentSize.width - self.scrollView.width)), self.scrollView.contentOffset.y);
            break;
        default: {
            CGFloat maxPage = self.championshipsViewControllers.allKeys.count - 1;
            CGFloat minPage = 0;
            CGFloat velocity = fabs([gestureRecognizer velocityInView:self.view].x);
            CGFloat progress = (self.gestureRecognizerInitialPositionX - touchX) / 320;
            [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:MIN(10, velocity / 30) options:UIViewAnimationOptionAllowUserInteraction animations:^{
                if (fabs(velocity) > 100 || progress > 0.5) {
                    if (self.gestureRecognizerInitialPositionX > touchX) {
                        self.scrollViewCurrentPage = MIN(maxPage, self.scrollViewCurrentPage + 1);
                    } else {
                        self.scrollViewCurrentPage = MAX(minPage, self.scrollViewCurrentPage - 1);
                    }
                }
                self.scrollView.contentOffset = CGPointMake(self.scrollView.width * self.scrollViewCurrentPage, self.scrollView.contentOffset.y);
            } completion:nil];
            break;
        }
    }
}

#pragma mark - Delegates & Data sources

#pragma mark - NSFetchedResultsController delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [super controllerDidChangeContent:controller];
    
    [self reloadScrollView];
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
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
    self.scrollView.scrollEnabled = NO;
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
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    [self.scrollView addGestureRecognizer:self.panGestureRecognizer];
    
    [self reloadData];
    [self reloadScrollView];
    
    self.scrollViewCurrentPage = 0;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kFTNotificationAuthenticationChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self reloadData];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self reloadWallet];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMatchesNavigationBarTitleAnimateKey object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self reloadManagedLeaguesViewController];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.scrollViewCurrentPage = self.scrollViewCurrentPage;
    [self reloadWallet];
    
    if (FBTweakValue(@"UX", @"Wallet", @"Glowing Button", YES) && [User currentUser].canRecharge) {
        self.navigationBarTitleView.moneyButton.numberOfAnimations = 3;
        self.navigationBarTitleView.moneyButton.animating = YES;
    }
    
    if (FBTweakValue(@"UX", @"Wallet", @"Daily Bonus", YES) && (![[NSUserDefaults standardUserDefaults] objectForKey:kPrizeLatestFetch] || fabs([[NSDate date] timeIntervalSinceDate:[[NSUserDefaults standardUserDefaults] objectForKey:kPrizeLatestFetch]]) > kPrizeFetchInterval)) {
        [Prize getWithObject:[User currentUser].editableObject success:^(NSArray *prizes) {
            [prizes enumerateObjectsUsingBlock:^(Prize *prize, NSUInteger idx, BOOL *stop) {
                if (prize.type != PrizeTypeUnknown) {
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
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:NSManagedObjectContextDidSaveNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kMatchesNavigationBarTitleAnimateKey];
}

@end
