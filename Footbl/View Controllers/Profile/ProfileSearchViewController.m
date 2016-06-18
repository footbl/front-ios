//
//  ProfileSearchViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/10/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SPHipster/SPBlock.h>

#import "ProfileSearchViewController.h"
#import "FavoriteTableViewCell.h"
#import "FeaturedButton.h"
#import "FeaturedViewController.h"
#import "FriendsHelper.h"
#import "FTBClient.h"
#import "FTBUser.h"
#import "LoadingHelper.h"
#import "ProfileViewController.h"

@interface ProfileSearchViewController ()

@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSSet *dataSourceUsers;
@property (strong, nonatomic) NSArray *footblDataSource;
@property (strong, nonatomic) NSMutableArray *sectionsData;
@property (strong, nonatomic) NSMutableArray *globalSearch;
@property (assign, nonatomic) NSUInteger currentStringHash;
@property (assign, nonatomic) BOOL shouldShowKeyboard;

@end

static const NSString *kLocalSearch = @"local";
static const NSString *kGlobalSearch = @"global";
static const NSString *kSectionTitle = @"title";
static const NSString *kSectionIdentifier = @"identifier";

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
            
            //Caches kFTResponseParamIdentifier from users in a set
            NSMutableArray *userIDs = [[NSMutableArray alloc] init];
            for (NSDictionary *user in friends) {
                [userIDs addObject:user[@"identifier"]];
            }
            self.dataSourceUsers = [[NSSet alloc] initWithArray:userIDs];
            
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

- (NSMutableArray *)globalSearch {
    if (!_globalSearch) {
        _globalSearch = [[NSMutableArray alloc] init];
    }
    
    return _globalSearch;
}

- (NSMutableArray *)sectionsData {
    if (!_sectionsData) {
        _sectionsData = [[NSMutableArray alloc] init];
    }
    
    return  _sectionsData;
}

#pragma mark - Instance Methods

- (IBAction)featuredAction:(id)sender {
    [self.navigationController pushViewController:[[FeaturedViewController alloc] init] animated:YES];
}

- (void)configureCell:(FavoriteTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *userRepresentation;
    NSDictionary *sectionData = self.sectionsData[indexPath.section];
    if ([sectionData objectForKey:kSectionIdentifier] == kLocalSearch) {
        userRepresentation = self.dataSource[indexPath.row];
    }
    
    if ([sectionData objectForKey:kSectionIdentifier] == kGlobalSearch) {
        userRepresentation = self.globalSearch[indexPath.row];
    }
    
    cell.nameLabel.text = userRepresentation[@"name"];
    cell.usernameLabel.text = userRepresentation[@"username"];
    cell.verified = [userRepresentation[@"verified"] boolValue];
    [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:userRepresentation[@"picture"]] placeholderImage:cell.placeholderImage];
}

#pragma mark - Delegates & Data sources

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    [self.sectionsData removeAllObjects];
    NSDictionary *localFriendsSection = @{kSectionTitle : NSLocalizedString(@"Facebook friends", @""), kSectionIdentifier : kLocalSearch};
    if (self.dataSource.count > 0) {
        [self.sectionsData addObject:localFriendsSection];
    }
    
    NSDictionary *globalSearchSection = @{kSectionTitle : NSLocalizedString(@"Footbl users", @""), kSectionIdentifier : kGlobalSearch};
    if (self.globalSearch.count > 0) {
        [self.sectionsData addObject:globalSearchSection];
    }
    
    return self.sectionsData.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *sectionData = self.sectionsData[section];
    return [sectionData objectForKey:kSectionTitle];
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    header.textLabel.font = [UIFont fontWithName:kFontNameSystemMedium size:14];
    header.textLabel.textColor = [[UIColor ftb_cellMatchPotColor] colorWithAlphaComponent:1.0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *sectionData = self.sectionsData[section];
    if ([sectionData objectForKey:kSectionIdentifier] == kLocalSearch) {
        return self.dataSource.count;
    }
    
    if ([sectionData objectForKey:kSectionIdentifier] == kGlobalSearch) {
        return self.globalSearch.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FavoriteTableViewCell *cell = (FavoriteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FavoriteCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *userRepresentation;
    NSDictionary *sectionData = self.sectionsData[indexPath.section];
    if ([sectionData objectForKey:kSectionIdentifier] == kLocalSearch) {
        userRepresentation = self.dataSource[indexPath.row];
    }
    
    if ([sectionData objectForKey:kSectionIdentifier] == kGlobalSearch) {
        userRepresentation = self.globalSearch[indexPath.row];
    }
	
	[[LoadingHelper sharedInstance] showHud];
	[[FTBClient client] user:userRepresentation[@"identifier"] success:^(FTBUser *user) {
		[[LoadingHelper sharedInstance] hideHud];
		ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
		profileViewController.user = user;
		[self.navigationController pushViewController:profileViewController animated:YES];
	} failure:^(NSError *error) {
		[[LoadingHelper sharedInstance] hideHud];
	}];
}

#pragma mark - UISearchBar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // Decides where to enqueue or cancel API request
    NSUInteger stringHash = [searchText hash];
    if (stringHash != self.currentStringHash) {
        //Cancels last pending block action from triggering
        if (self.currentStringHash != 0) {
            cancel_block(self.currentStringHash);
        }
        
        NSString *trimmedSearchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (trimmedSearchText.length == 0) {
            self.dataSource = nil;
        } else {
            //Local search
            self.dataSource = [self.footblDataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] %@ OR username BEGINSWITH[cd] %@", trimmedSearchText, trimmedSearchText]];
            
            //Global search
            perform_block_after_delay_k(0.5, &stringHash, ^{
                [[FriendsHelper sharedInstance] searchFriendsWithQuery:searchText existingUsers:self.dataSourceUsers completionBlock:^(NSArray *friends, NSError *error) {
                    [self.globalSearch addObjectsFromArray:friends];
                    [self.tableView reloadData];
                }];
            });
            
            self.currentStringHash = stringHash;
        }
        
        [self.globalSearch removeAllObjects];
        [self.tableView reloadData];
    }
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Search", @"");
    self.view.backgroundColor = [UIColor ftb_viewMatchBackgroundColor];
    
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
    self.searchBar.backgroundImage = [[UIImage alloc] init];
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
