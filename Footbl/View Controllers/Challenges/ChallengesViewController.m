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

- (NSMutableArray<FTBChallenge *> *)createChallenges {
    NSMutableArray *challenges = [[NSMutableArray alloc] init];

    FTBTeam *guest = [[FTBTeam alloc] init];
    guest.name = @"Corinthians";
    guest.pictureURL = [NSURL URLWithString:@"http://res.cloudinary.com/hqsehn3vw/image/upload/pxaj6hxamzuakwzz9q8t.png"];
    guest.grayscalePictureURL = [NSURL URLWithString:@"http://res.cloudinary.com/hqsehn3vw/image/upload/e_grayscale/pxaj6hxamzuakwzz9q8t.png"];

    FTBTeam *host = [[FTBTeam alloc] init];
    host.name = @"Palmeiras";
    host.pictureURL = [NSURL URLWithString:@"http://res.cloudinary.com/hqsehn3vw/image/upload/p2rwvgnninadpvdjefnc.png"];
    host.grayscalePictureURL = [NSURL URLWithString:@"http://res.cloudinary.com/hqsehn3vw/image/upload/e_grayscale/p2rwvgnninadpvdjefnc.png"];

    FTBUser *me = [FTBUser currentUser];

    FTBUser *opponent = [[FTBUser alloc] init];
    opponent.pictureURL = [NSURL URLWithString:@"https://pbs.twimg.com/profile_images/378800000483764274/ebce94fb34c055f3dc238627a576d251_400x400.jpeg"];
    opponent.identifier = @"123";

    NSDate *date = [NSDate date];

    for (FTBUser *user in @[me, opponent]) {
        for (NSNumber *elapsed in @[@0, @42]) {
            for (NSNumber *accepted in @[@NO, @YES]) {
                for (NSNumber *finished in @[@NO, @YES]) {
                    for (NSNumber *result in @[@(FTBMatchResultGuest), @(FTBMatchResultHost), @(FTBMatchResultDraw), @(FTBMatchResultUnknown)]) {
                        FTBMatch *match = [[FTBMatch alloc] init];
                        match.finished = finished.boolValue;
                        match.elapsed = elapsed.doubleValue;
                        match.guest = guest;
                        match.host = host;
                        match.result = result.integerValue;
                        match.date = date;
                        match.guestScore = (match.result == FTBMatchResultGuest) ? @1 : @0;
                        match.hostScore = (match.result == FTBMatchResultHost) ? @1 : @0;

                        if (match.finished && match.elapsed > 0) {
                            continue;
                        }

                        if (!match.finished && match.elapsed == 0 && match.result != FTBMatchResultUnknown) {
                            continue;
                        }

                        FTBChallenge *challenge = [[FTBChallenge alloc] init];
                        challenge.match = match;
                        challenge.accepted = accepted.boolValue;
                        challenge.bid = @10;
                        challenge.challengerUser = user;
                        challenge.challengerResult = FTBMatchResultHost;
                        challenge.challengedUser = user.isMe ? opponent : me;

                        if (accepted.boolValue) {
                            challenge.challengedResult = FTBMatchResultGuest;
                        }

                        [challenges addObject:challenge];
                    }
                }
            }
        }
    }

    return challenges;
}

#pragma mark - Instance Methods

- (void)configureCell:(ChallengeTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    FTBChallenge *challenge = self.challenges[indexPath.row];
    FTBMatchResult myResult = challenge.myResult;

    UIImage *placeholderImage = [UIImage imageNamed:@"placeholder_escudo"];

    if (myResult == FTBMatchResultHost) {
        [cell.hostTeamImageView sd_setImageWithURL:challenge.match.host.pictureURL placeholderImage:placeholderImage];
        [cell.guestTeamImageView sd_setImageWithURL:challenge.match.guest.grayscalePictureURL placeholderImage:placeholderImage];
        cell.hostTeamImageView.alpha = 1;
        cell.guestTeamImageView.alpha = 0.4;
        cell.vsLabel.alpha = 0.4;
    } else if (myResult == FTBMatchResultGuest) {
        [cell.hostTeamImageView sd_setImageWithURL:challenge.match.host.grayscalePictureURL placeholderImage:placeholderImage];
        [cell.guestTeamImageView sd_setImageWithURL:challenge.match.guest.pictureURL placeholderImage:placeholderImage];
        cell.hostTeamImageView.alpha = 0.4;
        cell.guestTeamImageView.alpha = 1;
        cell.vsLabel.alpha = 0.4;
    } else if (myResult == FTBMatchResultDraw) {
        [cell.hostTeamImageView sd_setImageWithURL:challenge.match.host.grayscalePictureURL placeholderImage:placeholderImage];
        [cell.guestTeamImageView sd_setImageWithURL:challenge.match.guest.grayscalePictureURL placeholderImage:placeholderImage];
        cell.hostTeamImageView.alpha = 0.4;
        cell.guestTeamImageView.alpha = 0.4;
        cell.vsLabel.alpha = 1;
    } else {
        [cell.hostTeamImageView sd_setImageWithURL:challenge.match.host.pictureURL placeholderImage:placeholderImage];
        [cell.guestTeamImageView sd_setImageWithURL:challenge.match.guest.pictureURL placeholderImage:placeholderImage];
        cell.hostTeamImageView.alpha = 1;
        cell.guestTeamImageView.alpha = 1;
        cell.vsLabel.alpha = 1;
    }

    cell.stakeLabel.text = challenge.accepted ? challenge.valueString : challenge.match.finished ? @"-" : @"?";
    cell.stakeLabel.textColor = challenge.match.finished ? [UIColor lightGrayColor] : [UIColor ftb_redStakeColor];
    cell.profitLabel.text = challenge.accepted ? challenge.rewardString : @"-";
    cell.profitLabel.textColor = challenge.match.finished ? [UIColor lightGrayColor] : [UIColor ftb_greenMoneyColor];
    cell.dateLabel.text = challenge.match.dateString;
    cell.userImageView.user = challenge.oponent;
    cell.userImageView.ringVisible = challenge.accepted || !challenge.challengerUser.isMe;
    cell.topLineView.backgroundColor = (challenge.match.elapsed > 0) ? [UIColor ftb_greenLiveColor] : [UIColor ftb_cellSeparatorColor];
    cell.bottomLineView.backgroundColor = (challenge.match.elapsed > 0) ? [UIColor ftb_greenLiveColor] : [UIColor ftb_cellSeparatorColor];
}

- (void)setupInfiniteScrolling {
    __weak typeof(self) weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        weakSelf.page++;
        [[FTBClient client] challengesForChallenger:nil challenged:nil page:weakSelf.page success:^(NSArray *challenges) {
            [weakSelf.challenges addObjectsFromArray:challenges];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
            weakSelf.tableView.showsInfiniteScrolling = (challenges.count == FTBClientPageSize);
        } failure:^(NSError *error) {
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
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

- (void)test:(id)sender {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    self.challenges = [self createChallenges];
    self.tableView.showsInfiniteScrolling = NO;
    self.refreshControl.enabled = NO;
    [self.tableView reloadData];
}

- (void)done:(id)sender {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Test" style:UIBarButtonItemStylePlain target:self action:@selector(test:)];
    self.tableView.showsInfiniteScrolling = YES;
    self.refreshControl.enabled = YES;
    [self.refreshControl beginRefreshing];
    [self refreshAction:nil];
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

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Test" style:UIBarButtonItemStylePlain target:self action:@selector(test:)];

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
