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
#import "FootblPopupAnimatedTransition.h"
#import "FTAuthenticationManager.h"
#import "Entry.h"
#import "LoadingHelper.h"
#import "MatchesNavigationBarView.h"
#import "MatchesViewController.h"
#import "NSNumber+Formatter.h"
#import "RechargeViewController.h"
#import "UIFont+MaxFontSize.h"
#import "UILabel+MaxFontSize.h"
#import "UIView+Frame.h"
#import "User.h"

@interface BetsViewController ()

@property (strong, nonatomic) NSMutableDictionary *championshipsViewControllers;
@property (assign, nonatomic) CGFloat gestureRecognizerInitialPositionX;
@property (assign, nonatomic) NSInteger scrollViewCurrentPage;

@end

#pragma mark BetsViewController

@implementation BetsViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Championship"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"enabled = %@", @YES];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[FTModel managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
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
        matchesViewController.tableView.scrollsToTop = NO;
    }
    
    if (self.fetchedResultsController.fetchedObjects.count > 0) {
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
    if (FBTweakValue(@"UX", @"Profile", @"Transfers", NO)) {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[RechargeViewController new]];
        [self presentViewController:[[FootblPopupViewController alloc] initWithRootViewController:navigationController] animated:YES completion:nil];
        [self setNeedsStatusBarAppearanceUpdate];
        return;
    }
    
    if (![User currentUser].canRecharge) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Ops", @"") message:NSLocalizedString(@"Cannot update wallet due to wallet balance", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alert show];
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

- (NSTimeInterval)updateInterval {
    return UPDATE_INTERVAL_NEVER;
}

- (void)reloadScrollView {
    NSMutableDictionary *championshipsToRemove = self.championshipsViewControllers.mutableCopy;
    NSInteger index = 0;
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
        
        if (index == 0) {
            matchesViewController.headerSliderBackImageView.hidden = YES;
        }
        
        if (index + 1 == championships.count) {
            matchesViewController.headerSliderForwardImageView.hidden = YES;
        }
        
        matchesViewController.view.frame = CGRectMake(self.scrollView.frameWidth * index, 0, self.scrollView.frameWidth, self.scrollView.frameHeight);
        contentSize = CGSizeMake(CGRectGetMaxX(matchesViewController.view.frame), self.scrollView.frameHeight);
        [championshipsToRemove removeObjectForKey:championship.slug];
        index ++;
    }
    self.scrollView.contentSize = contentSize;
    self.scrollView.contentOffset = CGPointMake(MIN(MAX(0, contentSize.width - self.scrollView.frameWidth), self.scrollView.contentOffset.x), self.scrollView.contentOffset.y);
    
    [self.championshipsViewControllers removeObjectsForKeys:championshipsToRemove.allKeys];
    for (UIViewController *viewController in championshipsToRemove.allValues) {
        [viewController removeFromParentViewController];
        [viewController.view removeFromSuperview];
    }
}

- (void)reloadData {
    [self reloadWallet];

    FTOperationErrorBlock failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [[ErrorHandler sharedInstance] displayError:error];
    };
    
    if (![FTAuthenticationManager sharedManager].isAuthenticated) {
        return;
    }
    
    [Championship getWithObject:nil success:^(id response) {
        [Entry getWithObject:[User currentUser] success:^(id response) {

        } failure:failure];
    } failure:failure];
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
    
    [UIFont setMaxFontSizeToFitBoundsInLabels:labels];
}

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    CGFloat touchX = [gestureRecognizer locationInView:self.view].x;
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.gestureRecognizerInitialPositionX = touchX;
        case UIGestureRecognizerStateChanged:
            self.scrollView.contentOffset = CGPointMake(MAX(0, MIN(self.scrollViewCurrentPage * self.scrollView.frameWidth + self.gestureRecognizerInitialPositionX - touchX, self.scrollView.contentSize.width - self.scrollView.frameWidth)), self.scrollView.contentOffset.y);
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
                self.scrollView.contentOffset = CGPointMake(self.scrollView.frameWidth * self.scrollViewCurrentPage, self.scrollView.contentOffset.y);
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
    [self.navigationBarTitleView.moneyButton addTarget:self action:@selector(rechargeWalletAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.navigationBarTitleView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollEnabled = NO;
    self.scrollView.scrollsToTop = NO;
    [self.view insertSubview:self.scrollView belowSubview:self.navigationBarTitleView];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    [self.scrollView addGestureRecognizer:panGestureRecognizer];
    
    [self reloadData];
    [self reloadScrollView];
    
    self.scrollViewCurrentPage = 0;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kFTNotificationAuthenticationChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self reloadData];
    }];

}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.scrollViewCurrentPage = self.scrollViewCurrentPage;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    for (MatchesViewController *matchesViewController in self.championshipsViewControllers.allValues) {
        matchesViewController.tableView.scrollsToTop = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end