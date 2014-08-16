//
//  TransfersViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/29/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "CreditRequest.h"
#import "FootblTabBarController.h"
#import "FriendsHelper.h"
#import "ErrorHandler.h"
#import "LoadingHelper.h"
#import "NSParagraphStyle+AlignmentCenter.h"
#import "TransferTableViewCell.h"
#import "TransfersViewController.h"
#import "UIImage+Color.h"
#import "User.h"

@interface TransfersViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSArray *fbFriends;
@property (strong, nonatomic) NSMutableArray *pendingTransfers;

@end

#pragma mark TransfersViewController

@implementation TransfersViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CreditRequest"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"rid" ascending:YES]];
        switch (self.segmentedControl.selectedSegmentIndex) {
            case 0:
                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"chargedUser.slug = %@", [User currentUser].slug];
                break;
            default:
                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"creditedUser.slug = %@", [User currentUser].slug];
                break;
        }
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[FTModel managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
        self.fetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![_fetchedResultsController performFetch:&error]) {
            SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return _fetchedResultsController;
}

#pragma mark - Instance Methods

- (id)init {
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (IBAction)segmentedControlAction:(id)sender {
    self.fetchedResultsController = nil;
    [self.tableView reloadData];
    
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            self.tableView.frame = CGRectMake(0, self.tableView.frame.origin.y, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - self.tableView.frame.origin.y - 66);
            self.sendButton.hidden = NO;
            break;
        default:
            self.tableView.frame = CGRectMake(0, self.tableView.frame.origin.y, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - self.tableView.frame.origin.y);
            self.sendButton.hidden = YES;
            break;
    }
}

- (IBAction)sendMoneyAction:(id)sender {
    if (self.pendingTransfers.count == 0) {
        return;
    }
    
    FTOperationErrorBlock failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [[LoadingHelper sharedInstance] hideHud];
        [[ErrorHandler sharedInstance] displayError:error];
    };
    
    [CreditRequest payRequests:self.pendingTransfers success:^(id response) {
        [CreditRequest getWithObject:[User currentUser] success:^(id response) {
            [CreditRequest getRequestsWithObject:[User currentUser] success:^(id response) {
                [[LoadingHelper sharedInstance] hideHud];
            } failure:failure];
        } failure:failure];
    } failure:failure];
}

- (NSInteger)userWallet {
    NSInteger totalTransfers = [User currentUser].localFunds.integerValue;
    for (CreditRequest *request in self.pendingTransfers) {
        totalTransfers -= request.valueValue;
    }
    return totalTransfers;
}

- (void)setupLabels {
    NSMutableDictionary *textAttributes = [@{} mutableCopy];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultCenterAlignmentParagraphStyle] mutableCopy];
    paragraphStyle.lineHeightMultiple = 0.55;
    textAttributes[NSParagraphStyleAttributeName] = paragraphStyle;
    textAttributes[NSForegroundColorAttributeName] = [UIColor ftGreenMoneyColor];
    textAttributes[NSFontAttributeName] = [UIFont fontWithName:kFontNameMedium size:25];
    textAttributes[NSKernAttributeName] = @(0.1);
    
    NSMutableAttributedString *walletText = [NSMutableAttributedString new];
    NSMutableAttributedString *stakeText = [NSMutableAttributedString new];
    
    [walletText appendAttributedString:[[NSAttributedString alloc] initWithString:[[@([self userWallet]) stringValue] stringByAppendingString:@"\n"] attributes:textAttributes]];
    textAttributes[NSForegroundColorAttributeName] = [UIColor ftRedStakeColor];
    [stakeText appendAttributedString:[[NSAttributedString alloc] initWithString:[[User currentUser].localStake.stringValue stringByAppendingString:@"\n"] attributes:textAttributes]];
    textAttributes[NSForegroundColorAttributeName] = [UIColor ftGreenMoneyColor];
    
    textAttributes[NSFontAttributeName] = [UIFont fontWithName:kFontNameLight size:12];
    textAttributes[NSKernAttributeName] = @(0.1);
    [walletText appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Wallet", @"") attributes:textAttributes]];
    textAttributes[NSForegroundColorAttributeName] = [UIColor ftRedStakeColor];
    [stakeText appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Stake", @"") attributes:textAttributes]];
    
    self.walletLabel.attributedText = walletText;
    self.stakeLabel.attributedText = stakeText;
}

- (void)reloadWallet {
    [self setupLabels];
    
    self.sendButton.enabled = (self.pendingTransfers.count > 0);
}

- (void)reloadData {
    [super reloadData];
    
    [[LoadingHelper sharedInstance] showHud];
    
    FTOperationErrorBlock failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.refreshControl endRefreshing];
        [[LoadingHelper sharedInstance] hideHud];
        [[ErrorHandler sharedInstance] displayError:error];
    };
    
    [[FriendsHelper sharedInstance] getFbFriendsWithCompletionBlock:^(NSArray *fbFriends, NSError *error) {
        [[FriendsHelper sharedInstance] getFbInvitableFriendsWithCompletionBlock:^(NSArray *invFriends, NSError *error) {
            self.fbFriends = [fbFriends arrayByAddingObjectsFromArray:invFriends];
            [self.tableView reloadData];
            [CreditRequest getWithObject:[User currentUser] success:^(id response) {
                [CreditRequest getRequestsWithObject:[User currentUser] success:^(id response) {
                    [self.refreshControl endRefreshing];
                    [[LoadingHelper sharedInstance] hideHud];
                } failure:failure];
            } failure:failure];
        }];
    }];
}

- (void)configureCell:(TransferTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    CreditRequest *request = [self.fetchedResultsController objectAtIndexPath:indexPath];
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            cell.nameLabel.text = request.creditedUser.name;
            cell.valueLabel.hidden = NO;
            [cell setEnabled:!request.payedValue];
            if (request.payedValue) {
                cell.valueLabel.hidden = YES;
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.valueLabel.hidden = NO;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        default:
            cell.nameLabel.text = request.chargedUser.name;
            if (request.payedValue) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                cell.valueLabel.hidden = YES;
                [cell setEnabled:NO];
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.valueLabel.hidden = NO;
                [cell setEnabled:YES];
            }
            break;
    }
    
    cell.valueLabel.text = request.value.stringValue;
    
    User *user = nil;
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        user = request.creditedUser;
    } else {
        user = request.chargedUser;
    }
    
    if (user) {
        cell.nameLabel.text = user.name;
        [cell.profileImageView setImageWithURL:[NSURL URLWithString:user.picture] placeholderImage:cell.placeholderImage];
    } else if (request.facebookId.length > 0) {
        NSDictionary *friend = [self.fbFriends filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id = %@", request.facebookId]].firstObject;
        cell.nameLabel.text = friend[@"name"];
        if ([friend[@"picture"][@"data"][@"is_silhouette"] boolValue]) {
            [cell.profileImageView cancelCurrentImageLoad];
            [cell restoreProfileImagePlaceholder];
        } else {
            [cell.profileImageView setImageWithURL:[NSURL URLWithString:friend[@"picture"][@"data"][@"url"]] placeholderImage:cell.placeholderImage];
        }
    }
}

#pragma mark - Delegates & Data sources

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TransferTableViewCell *cell = (TransferTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CreditCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CreditRequest *request = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (request.payedValue || self.segmentedControl.selectedSegmentIndex != 0 || [self userWallet] - request.valueValue < 100) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    [self.pendingTransfers addObject:request];
    [self reloadWallet];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    CreditRequest *request = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (request.payedValue || self.segmentedControl.selectedSegmentIndex != 0) {
        return;
    }
    
    [self.pendingTransfers removeObject:request];
    [self reloadWallet];
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Transfers", @"");
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    self.view.clipsToBounds = NO;
    
    self.pendingTransfers = [NSMutableArray new];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 100)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerView.backgroundColor = [UIColor colorWithRed:0.99 green:0.99 blue:0.99 alpha:1];
    [self.view addSubview:headerView];
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Send to", @""), NSLocalizedString(@"Received from", @"")]];
    self.segmentedControl.frame = CGRectMake(7, 13, CGRectGetWidth(self.view.frame) - 14, 29);
    self.segmentedControl.tintColor = [FootblAppearance colorForView:FootblColorTabBarTint];
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.backgroundColor = headerView.backgroundColor;
    [self.segmentedControl addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    [headerView addSubview:self.segmentedControl];
    
    self.walletLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(self.segmentedControl.frame) + 8, CGRectGetWidth(self.view.frame) / 2, CGRectGetHeight(headerView.frame) - CGRectGetMaxY(self.segmentedControl.frame))];
    self.walletLabel.numberOfLines = 2;
    [headerView addSubview:self.walletLabel];
    
    self.stakeLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) / 2) - 5, CGRectGetMaxY(self.segmentedControl.frame) + 8, CGRectGetWidth(self.view.frame) / 2, CGRectGetHeight(headerView.frame) - CGRectGetMaxY(self.segmentedControl.frame))];
    self.stakeLabel.numberOfLines = 2;
    [headerView addSubview:self.stakeLabel];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(headerView.frame) - 0.5, CGRectGetWidth(self.view.frame), 0.5)];
    separatorView.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1];
    separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [headerView addSubview:separatorView];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    tableViewController.refreshControl = self.refreshControl;
    
    self.tableView = tableViewController.tableView;
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(headerView.frame) - 66);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = 58;
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.separatorColor = separatorView.backgroundColor;
    [self.tableView registerClass:[TransferTableViewCell class] forCellReuseIdentifier:@"CreditCell"];
    [self.view insertSubview:self.tableView belowSubview:separatorView];
    
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 66, CGRectGetWidth(self.view.frame), 66)];
    self.sendButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.sendButton.titleLabel.font = [UIFont fontWithName:kFontNameMedium size:19];
    [self.sendButton setTitle:NSLocalizedString(@"Send $", @"") forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0.21 green:0.78 blue:0.46 alpha:1]] forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendMoneyAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendButton];
    
    [self setupLabels];
    [self reloadData];
    [self reloadWallet];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [(FootblTabBarController *)self.tabBarController tabBarSeparatorView].alpha = 0;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [(FootblTabBarController *)self.tabBarController tabBarSeparatorView].alpha = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
