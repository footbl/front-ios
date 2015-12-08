//
//  ProfileBetsViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/31/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <SVPullToRefresh/SVPullToRefresh.h>
#import "LoadingHelper.h"
#import "MatchTableViewCell+Setup.h"
#import "ProfileBetsViewController.h"

#import "FTBClient.h"
#import "FTBUser.h"
#import "FTBBet.h"
#import "FTBMatch.h"

@interface ProfileBetsViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (assign, nonatomic) NSInteger numberOfMatches;
@property (assign, nonatomic) NSUInteger nextPage;

@end

#pragma mark ProfileBetsViewController

@implementation ProfileBetsViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (NSTimeInterval)updateInterval {
    return UPDATE_INTERVAL_NEVER;
}

- (void)reloadData {
    [super reloadData];
	
	__weak typeof(self) this = self;
	[[FTBClient client] betsForUser:self.user match:nil page:0 success:^(NSArray *bets) {
		[this setupInfiniteScrolling];
		this.tableView.showsInfiniteScrolling = (bets.count == FT_API_PAGE_LIMIT);
		this.nextPage++;
		[this.refreshControl endRefreshing];
		[[LoadingHelper sharedInstance] hideHud];
	} failure:^(NSError *error) {
		[this.refreshControl endRefreshing];
		[[LoadingHelper sharedInstance] hideHud];
		[[ErrorHandler sharedInstance] displayError:error];
	}];
}

- (void)configureCell:(MatchTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    FTBBet *bet = self.bets[indexPath.row];
    [cell setMatch:bet.match bet:bet viewController:self selectionBlock:nil];
}

- (void)setupInfiniteScrolling {
    if (self.tableView.infiniteScrollingView) {
        return;
    }
	
	__weak typeof(self) this = self;
    [this.tableView addInfiniteScrollingWithActionHandler:^{
        [super reloadData];
        
        if (this.bets.count == 0) {
            [[LoadingHelper sharedInstance] showHud];
        }
 
		[[FTBClient client] betsForUser:self.user match:nil page:0 success:^(NSArray *bets) {
			[this.tableView.infiniteScrollingView stopAnimating];
			[[LoadingHelper sharedInstance] hideHud];
			if (bets.count == FT_API_PAGE_LIMIT) {
				this.tableView.showsInfiniteScrolling = YES;
			} else {
				this.nextPage++;
				this.tableView.showsInfiniteScrolling = NO;
			}
		} failure:^(NSError *error) {
			[this.tableView.infiniteScrollingView stopAnimating];
			[[LoadingHelper sharedInstance] hideHud];
			[[ErrorHandler sharedInstance] displayError:error];
		}];
    }];
}

#pragma mark - Delegates & Data sources

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.bets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MatchTableViewCell *cell = (MatchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MatchCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FTBBet *bet = self.bets[indexPath.row];
    CGFloat height = 340;
    if (bet.match.elapsed || bet.match.isFinished) {
        height = 363;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor ftb_viewMatchBackgroundColor];
    self.title = NSLocalizedString(@"Bet history", @"");
    
    self.numberOfMatches = self.bets.count;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    tableViewController.refreshControl = self.refreshControl;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kFTNotificationAuthenticationChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
    self.tableView = tableViewController.tableView;
    self.tableView.frame = self.view.bounds;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 5)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 5)];
    [self.tableView registerClass:[MatchTableViewCell class] forCellReuseIdentifier:@"MatchCell"];
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
