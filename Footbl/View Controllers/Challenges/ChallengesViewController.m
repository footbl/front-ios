//
//  ChallengesViewController.m
//  Footbl
//
//  Created by Leonardo Formaggio on 9/30/15.
//  Copyright © 2015 Footbl. All rights reserved.
//

#import "ChallengesViewController.h"
#import "FTBChallenge.h"
#import "FTBClient.h"
#import "FTBUser.h"
#import "ChallengeTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FTBTeam.h"
#import "FootblAppearance.h"

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
    
    FTBUser *user = [FTBUser currentUser];
    [[FTBClient client] challengesForChallenger:user challenged:nil page:0 success:^(id challenges) {
        self.challenges = challenges;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
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

@end
