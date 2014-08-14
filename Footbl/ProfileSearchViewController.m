//
//  ProfileSearchViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/10/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <SPHipster/SPBlock.h>
#import "FavoriteTableViewCell.h"
#import "FeaturedButton.h"
#import "FeaturedViewController.h"
#import "FriendsHelper.h"
#import "LoadingHelper.h"
#import "ProfileSearchViewController.h"
#import "ProfileViewController.h"
#import "User.h"

@interface ProfileSearchViewController ()

@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSArray *footblDataSource;
@property (assign, nonatomic) BOOL shouldShowKeyboard;

@end

#pragma mark ProfileSearchViewController

@implementation ProfileSearchViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (NSArray *)footblDataSource {
    if (!_footblDataSource) {
        _footblDataSource = @[];
        
        [[FriendsHelper sharedInstance] getFriendsWithCompletionBlock:^(NSArray *friends, NSError *error) {
            self.footblDataSource = friends;
            self.dataSource = nil;
            [self.tableView reloadData];
        }];
    }
    
    return _footblDataSource;
}

- (NSArray *)dataSource {
    if (!_dataSource) {
        _dataSource = self.footblDataSource;
    }
    
    return _dataSource;
}

#pragma mark - Instance Methods

- (IBAction)featuredAction:(id)sender {
    [self.navigationController pushViewController:[FeaturedViewController new] animated:YES];
}

- (void)configureCell:(FavoriteTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *userRepresentation = self.dataSource[indexPath.row];
    cell.nameLabel.text = userRepresentation[@"name"];
    cell.usernameLabel.text = userRepresentation[@"username"];
    cell.verified = [userRepresentation[@"verified"] boolValue];
    [cell.profileImageView setImageWithURL:[NSURL URLWithString:userRepresentation[@"picture"]] placeholderImage:cell.placeholderImage];
}

#pragma mark - Delegates & Data sources

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FavoriteTableViewCell *cell = (FavoriteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FavoriteCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileViewController *profileViewController = [ProfileViewController new];
    NSDictionary *userRepresentation = self.dataSource[indexPath.row];
    User *user = [User findOrCreateWithObject:userRepresentation inContext:[FTModel editableManagedObjectContext]];
    
    NSUInteger blockKey;
    perform_block_after_delay_k(0.5, &blockKey, ^{
        [[LoadingHelper sharedInstance] showHud];
    });
    
    [[FTModel editableManagedObjectContext] performBlock:^{
        [user updateWithData:userRepresentation];
        dispatch_async(dispatch_get_main_queue(), ^{
            cancel_block(blockKey);
            [[LoadingHelper sharedInstance] hideHud];
            profileViewController.user = user;
            [self.navigationController pushViewController:profileViewController animated:YES];
        });
    }];
}

#pragma mark - UISearchBar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString *text = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0) {
        self.dataSource = nil;
    } else {
        self.dataSource = [self.footblDataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] %@ OR username BEGINSWITH[cd] %@", text, text]];
    }
    [self.tableView reloadData];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
    
    /*
    if (scrollView.contentOffset.y > -18) {
        self.separatorView.alpha = 1;
    } else {
        self.separatorView.alpha = 0;
    }
    */
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Search", @"");
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.tableView = tableViewController.tableView;
    self.tableView.frame = self.view.bounds;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = 66;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[FavoriteTableViewCell class] forCellReuseIdentifier:@"FavoriteCell"];
    [self.view addSubview:self.tableView];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 47)];
    self.searchBar.barTintColor = [UIColor whiteColor];
    self.searchBar.backgroundColor = [UIColor colorWithRed:0.84 green:0.87 blue:0.85 alpha:1];
    self.searchBar.clipsToBounds = YES;
    self.searchBar.placeholder = NSLocalizedString(@"Type a friend's name", @"");
    self.searchBar.delegate = self;
    self.searchBar.backgroundImage = [UIImage new];
    self.tableView.tableHeaderView = self.searchBar;
    
    self.shouldShowKeyboard = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.tableView.indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.shouldShowKeyboard) {
        [self.searchBar becomeFirstResponder];
        self.shouldShowKeyboard = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
