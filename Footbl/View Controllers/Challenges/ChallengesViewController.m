//
//  ChallengesViewController.m
//  Footbl
//
//  Created by Leonardo Formaggio on 9/30/15.
//  Copyright © 2015 Footbl. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <SVPullToRefresh/UIScrollView+SVInfiniteScrolling.h>

#import "ChallengesViewController.h"
#import "ChallengeTableViewCell.h"
#import "ChallengeViewController.h"
#import "FootblAppearance.h"
#import "FTBChallenge.h"
#import "FTBClient.h"
#import "FTBTeam.h"
#import "FTBUser.h"
#import "LoadingHelper.h"

@interface ChallengesViewController ()

@property (nonatomic, strong) NSMutableArray *challenges;
@property (nonatomic) NSUInteger page;

@end

@implementation ChallengesViewController

#pragma mark - Class Methods

+ (NSString *)storyboardName {
    return @"Main";
}

#pragma mark - Instance Methods

- (void)configureCell:(ChallengeTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    FTBChallenge *challenge = self.challenges[indexPath.row];
    [cell.hostTeamImageView sd_setImageWithURL:challenge.match.host.pictureURL];
    [cell.guestTeamImageView sd_setImageWithURL:challenge.match.guest.pictureURL];
    cell.stakeLabel.text = challenge.valueString;
    cell.profitLabel.text = challenge.challengerResult == challenge.match.result ? challenge.valueString : @"-";
    cell.dateLabel.text = challenge.match.dateString;
    cell.guestTeamImageView.enabled = challenge.myResult == FTBMatchResultGuest;
    cell.hostTeamImageView.enabled = challenge.myResult == FTBMatchResultHost;
    cell.vsLabel.alpha = challenge.myResult == FTBMatchResultDraw ? 1 : 0.4;
    cell.userImageView.user = challenge.oponent;
    cell.userImageView.ringVisible = challenge.accepted || challenge.match.finished;
}

- (void)setupInfiniteScrolling {
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        self.page++;
        [[FTBClient client] challengesForChallenger:nil challenged:nil page:self.page success:^(NSArray *challenges) {
            [self.challenges addObjectsFromArray:challenges];
            [self.tableView reloadData];
            [self.tableView.infiniteScrollingView stopAnimating];
            self.tableView.showsInfiniteScrolling = (challenges.count == FTBClientPageSize);
        } failure:^(NSError *error) {
            [self.tableView.infiniteScrollingView stopAnimating];
        }];
    }];
}

#pragma mark - Actions

- (IBAction)refreshAction:(id)sender {
    self.page = 0;
    [[FTBClient client] challengesForChallenger:nil challenged:nil page:0 success:^(NSArray *challenges) {
        self.challenges = [[NSMutableArray alloc] initWithArray:challenges];
        [self.tableView reloadData];
        self.tableView.showsInfiniteScrolling = (challenges.count == FTBClientPageSize);
        [self.refreshControl endRefreshing];
    } failure:^(NSError *error) {
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - Lifecycle

- (void)commomInit {
    self.title = NSLocalizedString(@"Challenges", nil);
    
    UIImage *image = [UIImage imageNamed:@"GKTabBarIconChallengesOff"];
    UIImage *selectedImage = [UIImage imageNamed:@"GKTabBarIconChallengesOn"];
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title image:image selectedImage:selectedImage];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commomInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commomInit];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupInfiniteScrolling];

    [self.refreshControl beginRefreshing];
    [self refreshAction:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.challenges.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ChallengeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FTBChallenge *challenge = self.challenges[indexPath.row];
    ChallengeViewController *viewController = [[ChallengeViewController alloc] init];
    viewController.challenge = challenge;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
