//
//  FavoritesViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/23/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <SPHipster/SPLog.h>
#import "FavoriteTableViewCell.h"
#import "FavoritesViewController.h"
#import "FeaturedButton.h"
#import "FeaturedViewController.h"
#import "ProfileSearchViewController.h"
#import "ProfileViewController.h"

#import "FTBClient.h"
#import "FTBUser.h"

@interface FavoritesViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

#pragma mark FavoritesViewController

@implementation FavoritesViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (instancetype)init {
    if (self) {
        self.title = NSLocalizedString(@"Favorites", @"");
        
        UIImage *image = [UIImage imageNamed:@"tabbar-favorites"];
        UIImage *selectedImage = [UIImage imageNamed:@"tabbar-favorites-selected"];
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title image:image selectedImage:selectedImage];
    }
    return self;
}

- (IBAction)featuredAction:(id)sender {
    [self.navigationController pushViewController:[FeaturedViewController new] animated:YES];
}

- (IBAction)searchAction:(id)sender {
    [self.navigationController pushViewController:[ProfileSearchViewController new] animated:YES];
}

- (void)configureCell:(FavoriteTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    FTBUser *user = self.favorites[indexPath.row];
    cell.nameLabel.text = user.name;
    cell.usernameLabel.text = user.username;
    cell.verified = user.isVerified;
    [cell.profileImageView sd_setImageWithURL:user.pictureURL placeholderImage:cell.placeholderImage];
}

- (void)reloadData {
    [super reloadData];
	
	[[FTBClient client] userFollowing:self.user success:^(id object) {
		[self.refreshControl endRefreshing];
	} failure:^(NSError *error) {
		[self.refreshControl endRefreshing];
		[[ErrorHandler sharedInstance] displayError:error];
	}];
}

#pragma mark - Delegates & Data sources

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.favorites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FavoriteTableViewCell *cell = (FavoriteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FavoriteCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.user.isMe;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FTBUser *user = self.favorites[indexPath.row];
		[[FTBClient client] unfollowUser:user.identifier success:nil failure:nil];
    }
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileViewController *profileViewController = [ProfileViewController new];
    profileViewController.user = self.favorites[indexPath.row];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Favorites", @"");
    self.view.backgroundColor = [UIColor ftb_viewMatchBackgroundColor];
    
    if (FBTweakValue(@"UX", @"Profile", @"Search", FT_ENABLE_SEARCH)) {
        UIBarButtonItem *searchButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_icn_search"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(searchAction:)];
        self.navigationItem.rightBarButtonItem = searchButtonItem;
    }
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    tableViewController.refreshControl = self.refreshControl;
    
    self.tableView = tableViewController.tableView;
    self.tableView.frame = self.view.bounds;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = 66;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.tableView registerClass:[FavoriteTableViewCell class] forCellReuseIdentifier:@"FavoriteCell"];
    [self.view addSubview:self.tableView];
    
    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kFTNotificationAuthenticationChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.tableView.indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}

@end
