//
//  GroupsViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <SPHipster/SPHipster.h>

#import "GroupsViewController.h"
#import "AnonymousViewController.h"
#import "FootblNavigationController.h"
#import "FTBChampionship.h"
#import "FTBClient.h"
#import "FTBGroup.h"
#import "FTBUser.h"
#import "GroupRankingViewController.h"
#import "GroupTableViewCell.h"
#import "NSString+Hex.h"
#import "UIImage+Text.h"

@interface GroupsViewController ()

@property (strong, nonatomic) AnonymousViewController *anonymousViewController;

@end

#pragma mark GroupsViewController

@implementation GroupsViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (id)init {
	self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Ranking", @"");
        
        UIImage *image = [UIImage imageNamed:@"GKTabBarIconFriendsOff"];
        UIImage *selectedImage = [UIImage imageNamed:@"GKTabBarIconFriendsOn"];
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title image:image selectedImage:selectedImage];
    }
    return self;
}

- (void)configureCell:(GroupTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    FTBGroup *group = self.groups[indexPath.row];
    cell.nameLabel.text = group.name;
    cell.groupImageView.image = group.iconImage;
    [cell setIndicatorHidden:YES animated:NO];
    [cell setUnreadCount:group.unreadMessagesCount];
    
    cell.bottomSeparatorView.hidden = (indexPath.section == 0 && [self numberOfSectionsInTableView:self.tableView] > 1 && indexPath.row + 1 == [self tableView:self.tableView numberOfRowsInSection:0]);
    cell.topSeparatorView.hidden = !(indexPath.section == 1 && [self numberOfSectionsInTableView:self.tableView] > 1 && indexPath.row == 0);
}

- (void)reloadData {
    [super reloadData];
	
    FTBGroup *world = [[FTBGroup alloc] init];
    world.type = FTBGroupTypeWorld;
    
    FTBGroup *country = [[FTBGroup alloc] init];
    country.type = FTBGroupTypeCountry;
    
    FTBGroup *friends = [[FTBGroup alloc] init];
    friends.type = FTBGroupTypeFriends;
    
    self.groups = @[world, country, friends];
}

#pragma mark - Delegates & Data sources

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupTableViewCell *cell = (GroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupRankingViewController *groupRankingViewController = [[GroupRankingViewController alloc] init];
    groupRankingViewController.group = self.groups[indexPath.row];
    [self.navigationController pushViewController:groupRankingViewController animated:YES];
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor ftb_viewMatchBackgroundColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.frame = self.view.bounds;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 96;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.tableView registerClass:[GroupTableViewCell class] forCellReuseIdentifier:@"GroupCell"];
    [self.view addSubview:self.tableView];
    
    self.anonymousViewController = [AnonymousViewController new];
    
    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kFTNotificationAuthenticationChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if ([[FTBClient client] isAuthenticated]) {
            [self reloadData];
        }
		
        if ([[FTBClient client] isAnonymous]) {
            [self addChildViewController:self.anonymousViewController];
            [self.view addSubview:self.anonymousViewController.view];
            self.navigationItem.rightBarButtonItem.enabled = NO;
        } else {
            [self.anonymousViewController.view removeFromSuperview];
            [self.anonymousViewController removeFromParentViewController];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.tableView.indexPathForSelectedRow) {
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
    
    if ([[FTBClient client] isAnonymous]) {
        [self addChildViewController:self.anonymousViewController];
        [self.view addSubview:self.anonymousViewController.view];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        [self.anonymousViewController.view removeFromSuperview];
        [self.anonymousViewController removeFromParentViewController];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.tableView reloadData];
}

@end
