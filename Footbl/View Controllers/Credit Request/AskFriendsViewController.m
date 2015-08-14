//
//  AskFriendsViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/30/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "AskFriendsViewController.h"
#import "AskFriendTableViewCell.h"
#import "CreditRequest.h"
#import "FriendsHelper.h"
#import "FTAuthenticationManager.h"
#import "LoadingHelper.h"

@interface AskFriendsViewController ()

@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSArray *fullDataSource;
@property (strong, nonatomic) NSSet *friendsSet;
@property (strong, nonatomic) NSSet *invitableFriendsSet;
@property (strong, nonatomic) NSMutableSet *selectedFriendsSet;
@property (assign, nonatomic, getter = isSelectAllActived) BOOL selectAllActived;

@end

#pragma mark AskFriendsViewController

@implementation AskFriendsViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (NSArray *)dataSource {
    if (!_dataSource) {
        if (self.friendsSet && self.invitableFriendsSet) {
            _dataSource = [[self.friendsSet.allObjects arrayByAddingObjectsFromArray:self.invitableFriendsSet.allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
            self.fullDataSource = self.dataSource;
        }
    }
    
    return _dataSource;
}

- (void)setFriendsSet:(NSSet *)friendsSet {
    _friendsSet = friendsSet;
    
    self.dataSource = nil;
}

- (void)setInvitableFriendsSet:(NSSet *)invitableFriendsSet {
    _invitableFriendsSet = invitableFriendsSet;
    
    self.dataSource = nil;
}

#pragma mark - Instance Methods

- (NSInteger)rowFromIndexPath:(NSIndexPath *)indexPath {
    if (self.searchBar.text.length > 0) {
        return indexPath.row;
    } else {
        return indexPath.row - 1;
    }
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendAction:(id)sender {
    __block NSMutableArray *ids = [[self.selectedFriendsSet.allObjects valueForKeyPath:@"id"] mutableCopy];
    __block NSMutableArray *successfullIds = [NSMutableArray new];
    __block NSMutableArray *failedIds = [NSMutableArray new];
    __block void(^runBlock)();
    __block FBSession *session;
    
    __block void(^fbBlock)(NSArray *fbIds) = ^(NSArray *fbIds) {
        NSMutableDictionary *fbParamsDictionary = [NSMutableDictionary new];
        NSUInteger idx = 0;
        for (id object in fbIds) {
            if (fbParamsDictionary.allKeys.count == 50) {
                return;
            }
            fbParamsDictionary[[NSString stringWithFormat:@"to[%lu]", (unsigned long)idx]] = object;

            idx ++;
        }
        
        [FBWebDialogs presentRequestsDialogModallyWithSession:session message:NSLocalizedString(@"Facebook request message", @"") title:NSLocalizedString(@"Facebook request title", @"") parameters:fbParamsDictionary handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
            if (error) {
                SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
                [[ErrorHandler sharedInstance] displayError:error];
                return;
            }
            if (result == FBWebDialogResultDialogCompleted) {
                [successfullIds addObjectsFromArray:fbIds];
            } else {
                [failedIds addObjectsFromArray:fbIds];
            }
            
            dispatch_async(dispatch_get_main_queue(), runBlock);
        }];
    };
    
    runBlock = ^() {
        NSMutableArray *tempIds = [NSMutableArray new];
        [tempIds addObjectsFromArray:[ids subarrayWithRange:NSMakeRange(0, MIN(50, ids.count))]];
        [ids removeObjectsInRange:NSMakeRange(0, MIN(50, ids.count))];
        if (tempIds.count == 0) {
            [[LoadingHelper sharedInstance] showHud];
            [CreditRequest createWithIds:successfullIds success:^(id response) {
                [[LoadingHelper sharedInstance] hideHud];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [[LoadingHelper sharedInstance] hideHud];
                [[ErrorHandler sharedInstance] displayError:error];
            }];
        } else {
            fbBlock(tempIds);
        }
    };
    
    [[FTAuthenticationManager sharedManager] authenticateFacebookWithCompletion:^(FBSession *fbSession, FBSessionState status, NSError *error) {
        session = fbSession;
        runBlock();
    }];
}

- (void)tapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self.searchBar resignFirstResponder];
}

- (void)reloadData {
    [[LoadingHelper sharedInstance] showHud];
    [[FTAuthenticationManager sharedManager] authenticateFacebookWithCompletion:^(FBSession *session, FBSessionState status, NSError *error) {
        [[FriendsHelper sharedInstance] getFbFriendsWithCompletionBlock:^(NSArray *friends, NSError *error) {
            self.friendsSet = [NSSet setWithArray:friends];
            [[FriendsHelper sharedInstance] getFbInvitableFriendsWithCompletionBlock:^(NSArray *friends, NSError *error) {
                self.invitableFriendsSet = [NSSet setWithArray:friends];
                self.dataSource = nil;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [[LoadingHelper sharedInstance] hideHud];
                });
            }];
        }];
    }];
}

- (void)configureCell:(AskFriendTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && self.searchBar.text.length == 0) {
        cell.nameLabel.text = NSLocalizedString(@"Select all", @"");
        cell.profileImageViewHidden = YES;
        
        if (self.isSelectAllActived) {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        } else if ([[self.tableView indexPathsForSelectedRows] containsObject:indexPath]) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
        return;
    }
    
    NSDictionary *friend = self.dataSource[[self rowFromIndexPath:indexPath]];
    cell.nameLabel.text = friend[@"name"];
    cell.profileImageViewHidden = NO;
    if ([friend[@"picture"][@"data"][@"is_silhouette"] boolValue]) {
        [cell.profileImageView sd_cancelCurrentImageLoad];
        [cell restoreProfileImagePlaceholder];
    } else {
        [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:friend[@"picture"][@"data"][@"url"]] placeholderImage:cell.placeholderImage];
    }
    
    if (self.selectAllActived || ([self.selectedFriendsSet containsObject:friend] && ![[self.tableView indexPathsForSelectedRows] containsObject:indexPath])) {
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

#pragma mark - Delegates & Data sources

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchBar.text.length > 0) {
        return self.dataSource.count;
    }
    
    if (self.dataSource.count > 0) {
        return self.dataSource.count + 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AskFriendTableViewCell *cell = (AskFriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && self.searchBar.text.length == 0) {
        [self.selectedFriendsSet removeAllObjects];
        [self.selectedFriendsSet addObjectsFromArray:self.fullDataSource];
        [self.tableView reloadData];
        self.selectAllActived = YES;
        return;
    }
    [self.selectedFriendsSet addObject:self.dataSource[[self rowFromIndexPath:indexPath]]];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectAllActived = NO;
    
    if (indexPath.row == 0 && self.searchBar.text.length == 0) {
        [self.selectedFriendsSet removeAllObjects];
        [self.tableView reloadData];
        return;
    }
    
    [self.selectedFriendsSet removeObject:self.dataSource[[self rowFromIndexPath:indexPath]]];
    [self.tableView reloadData];
}

#pragma mark - UISearchBar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString *text = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0) {
        self.dataSource = nil;
    } else {
        self.dataSource = [self.fullDataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] %@", text]];
    }
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    return YES;
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)]];
    [self.view insertSubview:backgroundView aboveSubview:self.headerImageView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.headerImageView.userInteractionEnabled = YES;
    self.selectedFriendsSet = [NSMutableSet new];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 58)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:18];
    titleLabel.text = NSLocalizedString(@"Ask for friends", @"");
    [self.headerImageView addSubview:titleLabel];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 58)];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 50);
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 58, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 58 - 60)];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.rowHeight = 57;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 8, 0, 8);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsMultipleSelection = YES;
    [self.tableView registerClass:[AskFriendTableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:self.tableView];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 43)];
    self.searchBar.barTintColor = [UIColor whiteColor];
    self.searchBar.backgroundColor = [UIColor colorWithRed:0.84 green:0.87 blue:0.85 alpha:1];
    self.searchBar.clipsToBounds = YES;
    self.searchBar.placeholder = NSLocalizedString(@"Type a friend's name", @"");
    self.searchBar.delegate = self;
    self.searchBar.backgroundImage = [UIImage new];
    self.tableView.tableHeaderView = self.searchBar;
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 118, CGRectGetWidth(self.view.frame), 0.5)];
    separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    separatorView.backgroundColor = [UIColor colorWithRed:0.69 green:0.92 blue:0.8 alpha:1];
    [self.view addSubview:separatorView];
    
    UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 61, CGRectGetWidth(self.view.frame), 61)];
    sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    sendButton.titleLabel.font = [UIFont fontWithName:kFontNameSystemMedium size:16];
    [sendButton setTitle:NSLocalizedString(@"Send", @"") forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor colorWithRed:52./255.f green:206/255.f blue:122/255.f alpha:1.0] forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor colorWithRed:52./255.f green:206/255.f blue:122/255.f alpha:0.4] forState:UIControlStateHighlighted];
    [sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendButton];
    
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
