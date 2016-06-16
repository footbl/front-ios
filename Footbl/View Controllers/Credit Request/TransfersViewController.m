//
//  TransfersViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/29/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "TransfersViewController.h"
#import "FootblTabBarController.h"
#import "FriendsHelper.h"
#import "FTBClient.h"
#import "FTBCreditRequest.h"
#import "FTBUser.h"
#import "LoadingHelper.h"
#import "NSParagraphStyle+AlignmentCenter.h"
#import "TransferTableViewCell.h"
#import "UIImage+Color.h"
#import "UIView+Frame.h"

@interface TransfersViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSArray *fbFriends;
@property (strong, nonatomic) NSMutableArray *pendingTransfers;

@end

#pragma mark TransfersViewController

@implementation TransfersViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (id)init {
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (IBAction)segmentedControlAction:(id)sender {
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
    
    [self reloadWallet];
}

- (IBAction)sendMoneyAction:(id)sender {
    if (self.pendingTransfers.count == 0) {
        return;
    }
    
    [[LoadingHelper sharedInstance] showHud];
    self.sendButton.userInteractionEnabled = NO;
    
    FTBBlockError failure = ^(NSError *error) {
        [[LoadingHelper sharedInstance] hideHud];
        [[ErrorHandler sharedInstance] displayError:error];
    };
	
	FTBUser *user = [FTBUser currentUser];
	for (FTBCreditRequest *request in self.pendingTransfers) {
		[[FTBClient client] approveCreditRequest:request.identifier success:^(id object) {
			[[FTBClient client] creditRequests:user chargedUser:nil page:0 success:^(id object) {
				self.sendButton.userInteractionEnabled = YES;
				[self.pendingTransfers removeAllObjects];
				[self reloadWallet];
				[[LoadingHelper sharedInstance] hideHud];
			} failure:failure];
		} failure:failure];
	}
}

- (NSInteger)userWallet {
	FTBUser *user = [FTBUser currentUser];
    NSInteger totalTransfers = user.funds.integerValue;
    for (FTBCreditRequest *request in self.pendingTransfers) {
        totalTransfers -= request.value.integerValue;
    }
    return totalTransfers;
}

- (void)setupLabels {
	FTBUser *user = [FTBUser currentUser];
	
    NSMutableDictionary *textAttributes = [@{} mutableCopy];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultCenterAlignmentParagraphStyle] mutableCopy];
    paragraphStyle.lineHeightMultiple = 0.55;
    textAttributes[NSParagraphStyleAttributeName] = paragraphStyle;
    textAttributes[NSForegroundColorAttributeName] = [UIColor ftb_greenMoneyColor];
    textAttributes[NSFontAttributeName] = [UIFont fontWithName:kFontNameMedium size:25];
    textAttributes[NSKernAttributeName] = @(0.1);
    
    NSMutableAttributedString *walletText = [NSMutableAttributedString new];
    NSMutableAttributedString *stakeText = [NSMutableAttributedString new];
    
    [walletText appendAttributedString:[[NSAttributedString alloc] initWithString:[[@([self userWallet]) stringValue] stringByAppendingString:@"\n"] attributes:textAttributes]];
    textAttributes[NSForegroundColorAttributeName] = [UIColor ftb_redStakeColor];
    [stakeText appendAttributedString:[[NSAttributedString alloc] initWithString:[user.stake.stringValue stringByAppendingString:@"\n"] attributes:textAttributes]];
    textAttributes[NSForegroundColorAttributeName] = [UIColor ftb_greenMoneyColor];
    
    textAttributes[NSFontAttributeName] = [UIFont fontWithName:kFontNameLight size:12];
    textAttributes[NSKernAttributeName] = @(0.1);
    [walletText appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Wallet", @"") attributes:textAttributes]];
    textAttributes[NSForegroundColorAttributeName] = [UIColor ftb_redStakeColor];
    [stakeText appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Stake", @"") attributes:textAttributes]];
    
    self.walletLabel.attributedText = walletText;
    self.stakeLabel.attributedText = stakeText;
}

- (void)reloadWallet {
    [self setupLabels];
    
    self.sendButton.enabled = (self.pendingTransfers.count > 0);
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        if (self.transfers.count == 0) {
            self.hintLabel.text = NSLocalizedString(@"No friends asked you for cash", @"");
        } else {
            self.hintLabel.text = NSLocalizedString(@"These friends need some cash:", @"");
        }
    } else {
        if (self.transfers.count == 0) {
            self.hintLabel.text = NSLocalizedString(@"No friends sent you cash", @"");
        } else {
            self.hintLabel.text = NSLocalizedString(@"These friends sent you some cash (✓):", @"");
        }
    }
}

- (void)reloadData {
    [super reloadData];
    
    [[LoadingHelper sharedInstance] showHud];
	
    [[FriendsHelper sharedInstance] getFbFriendsWithCompletionBlock:^(NSArray *fbFriends, NSError *error) {
        [[FriendsHelper sharedInstance] getFbInvitableFriendsWithCompletionBlock:^(NSArray *invFriends, NSError *error) {
            self.fbFriends = [fbFriends arrayByAddingObjectsFromArray:invFriends];
            [self.tableView reloadData];
			FTBUser *user = [FTBUser currentUser];
            [[FTBClient client] creditRequests:user chargedUser:nil page:0 success:^(id object) {
				[self.refreshControl endRefreshing];
				[[LoadingHelper sharedInstance] hideHud];
			} failure:^(NSError *error) {
				[self.refreshControl endRefreshing];
				[[LoadingHelper sharedInstance] hideHud];
				[[ErrorHandler sharedInstance] displayError:error];
			}];
        }];
    }];
}

- (void)configureCell:(TransferTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    FTBCreditRequest *request = self.transfers[indexPath.row];
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            cell.nameLabel.text = request.creditedUser.name;
            cell.valueLabel.hidden = NO;
            [cell setEnabled:!request.payed];
            if (request.payed) {
                cell.valueLabel.hidden = YES;
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.valueLabel.hidden = NO;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        default:
            cell.nameLabel.text = request.chargedUser.name;
            if (request.payed) {
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
    
    FTBUser *user = nil;
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        user = request.creditedUser;
    } else {
        user = request.chargedUser;
    }
    
    if (user) {
        cell.nameLabel.text = user.name;
        [cell.profileImageView sd_setImageWithURL:user.pictureURL placeholderImage:cell.placeholderImage];
    } else if (request.facebookId.length > 0) {
        NSDictionary *friend = [self.fbFriends filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id = %@", request.facebookId]].firstObject;
        cell.nameLabel.text = friend[@"name"];
        if ([friend[@"picture"][@"data"][@"is_silhouette"] boolValue]) {
            [cell.profileImageView sd_cancelCurrentImageLoad];
            [cell restoreProfileImagePlaceholder];
        } else {
            [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:friend[@"picture"][@"data"][@"url"]] placeholderImage:cell.placeholderImage];
        }
    }
}

#pragma mark - Delegates & Data sources

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.transfers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TransferTableViewCell *cell = (TransferTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CreditCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FTBCreditRequest *request = self.transfers[indexPath.row];
    if (request.payed) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }

    if (self.segmentedControl.selectedSegmentIndex != 0 || [self userWallet] - request.value.integerValue < 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.animationType = MBProgressHUDAnimationZoom;
        hud.labelText = NSLocalizedString(@"You need more cash!", @"");
        [hud hide:YES afterDelay:3];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    [self.pendingTransfers addObject:request];
    [self reloadWallet];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    FTBCreditRequest *request = self.transfers[indexPath.row];
    if (request.payed || self.segmentedControl.selectedSegmentIndex != 0) {
        return;
    }
    
    [self.pendingTransfers removeObject:request];
    [self reloadWallet];
}

#pragma mark - NSFetchedResultsController delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [super controllerDidChangeContent:controller];
    
    [self reloadWallet];
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Transfers", @"");
    self.view.backgroundColor = [UIColor ftb_viewMatchBackgroundColor];
    self.view.clipsToBounds = NO;
    
    self.pendingTransfers = [NSMutableArray new];
    
    CGFloat hintHeight = 30;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 100 + hintHeight)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerView.backgroundColor = [UIColor colorWithRed:0.99 green:0.99 blue:0.99 alpha:1];
    [self.view addSubview:headerView];
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Send to", @""), NSLocalizedString(@"Received from", @"")]];
    self.segmentedControl.frame = CGRectMake(7, 13, CGRectGetWidth(self.view.frame) - 14, 29);
    self.segmentedControl.tintColor = [UIColor ftb_tabBarTintColor];
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.backgroundColor = headerView.backgroundColor;
    [self.segmentedControl addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    [headerView addSubview:self.segmentedControl];
    
    self.walletLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(self.segmentedControl.frame) + 8, CGRectGetWidth(self.view.frame) / 2, CGRectGetHeight(headerView.frame) - CGRectGetMaxY(self.segmentedControl.frame) - hintHeight)];
    self.walletLabel.numberOfLines = 2;
    [headerView addSubview:self.walletLabel];
    
    self.stakeLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) / 2) - 5, CGRectGetMaxY(self.segmentedControl.frame) + 8, CGRectGetWidth(self.view.frame) / 2, CGRectGetHeight(headerView.frame) - CGRectGetMaxY(self.segmentedControl.frame) - hintHeight)];
    self.stakeLabel.numberOfLines = 2;
    [headerView addSubview:self.stakeLabel];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(headerView.frame) - hintHeight - 0.5, CGRectGetWidth(self.view.frame), 0.5)];
    separatorView.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1];
    separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [headerView addSubview:separatorView];
    
    self.hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, headerView.height - hintHeight, headerView.width, hintHeight)];
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    self.hintLabel.font = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:14];
    self.hintLabel.textColor = [[UIColor ftb_cellMatchPotColor] colorWithAlphaComponent:1.0];
    [headerView addSubview:self.hintLabel];
    
    separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(headerView.frame) - 0.5, CGRectGetWidth(self.view.frame), 0.5)];
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

@end
