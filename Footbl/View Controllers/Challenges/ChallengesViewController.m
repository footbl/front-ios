//
//  ChallengesViewController.m
//  Footbl
//
//  Created by Leonardo Formaggio on 9/30/15.
//  Copyright © 2015 Footbl. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>

#import "ChallengesViewController.h"
#import "ChallengeTableViewCell.h"
#import "FootblAppearance.h"
#import "FTBChallenge.h"
#import "FTBClient.h"
#import "FTBTeam.h"
#import "FTBUser.h"

@interface ChallengesViewController ()

@property (nonatomic, strong) NSMutableArray *challenges;

@end

@implementation ChallengesViewController

#pragma mark - Class Methods

+ (NSString *)storyboardName {
    return @"Main";
}

#pragma mark - Instance Methods

- (void)configureCell:(ChallengeTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    FTBChallenge *challenge = self.challenges[indexPath.row];
    [cell.userImageView sd_setImageWithURL:challenge.challengedUser.pictureURL placeholderImage:[UIImage imageNamed:@"FriendsGenericProfilePic"]];
    [cell.hostTeamImageView sd_setImageWithURL:challenge.match.host.pictureURL];
    [cell.guestTeamImageView sd_setImageWithURL:challenge.match.guest.pictureURL];
    cell.stakeLabel.text = challenge.valueString;
    cell.profitLabel.text = challenge.challengerResult == challenge.match.result ? challenge.valueString : @"-";
    cell.dateLabel.text = challenge.match.dateString;
}

#pragma mark - Lifecycle

- (void)commomInit {
    // TODO: Localization missing
    self.title = @"Challenges";
    
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

    [[FTBClient client] challengesForChallenger:nil challenged:nil page:0 success:^(id challenges) {
        self.challenges = challenges;
        [self.tableView reloadData];
    } failure:nil];
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

}

@end
