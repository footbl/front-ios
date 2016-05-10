//
//  ChallengeViewController.m
//  Footbl
//
//  Created by Leonardo Formaggio on 5/2/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import "ErrorHandler.h"
#import "ChallengeViewController.h"
#import "MatchTableViewCell.h"
#import "FTBUser.h"
#import "FTBMatch.h"
#import "FTBChallenge.h"
#import "MatchesNavigationBarView.h"
#import "MatchTableViewCell+Setup.h"
#import "NSNumber+Formatter.h"
#import "MatchesNavigationBarView.h"
#import "RechargeButton.h"
#import "UIFont+MaxFontSize.h"
#import "UIView+Frame.h"
#import "FootblTabBarController.h"
#import "ChallengeStatusTableViewCell.h"
#import "FTBClient.h"
#import "LoadingHelper.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface ChallengeViewController ()

@property (nonatomic, copy) NSNumber *bid;
@property (nonatomic) FTBMatchResult result;

@end

@implementation ChallengeViewController

#pragma mark - Instance Methods

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[MatchTableViewCell class]]) {
        [self configureMatchCell:(MatchTableViewCell *)cell atIndexPath:indexPath];
    } else if ([cell isKindOfClass:[ChallengeStatusTableViewCell class]]) {
        [self configureStatusCell:(ChallengeStatusTableViewCell *)cell atIndexPath:indexPath];
    }
}

- (void)configureStatusCell:(ChallengeStatusTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (self.isChallenging) {
        cell.statusLabel.text = nil;
        cell.substatusLabel.text = nil;
    } else {
        cell.statusLabel.text = @"Waiting for oponent";
        cell.substatusLabel.text = @"$20 returnee to your wallet";
    }
}

- (void)configureMatchCell:(MatchTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    
    FTBUser *user = [FTBUser currentUser];
    FTBChallenge *challenge = self.challenge;
    if (!challenge && self.bid) {
        challenge = [[FTBChallenge alloc] init];
        challenge.challengerUser = user;
        challenge.bid = self.bid;
        challenge.challengerResult = self.result;
        challenge.match = self.match;
    }
    
    [cell setMatch:self.match challenge:challenge viewController:self selectionBlock:^(NSInteger index) {
        NSUInteger firstBetValue = MAX(floor((user.funds.integerValue + user.stake.integerValue) / 100), 1);
        NSInteger currentBet = weakSelf.bid.integerValue;
        FTBMatchResult result = weakSelf.result;
        
        switch (index) {
            case 0: // Host
                if (result == FTBMatchResultHost) {
                    currentBet++;
                } else if (currentBet == 0) {
                    currentBet = firstBetValue;
                    result = FTBMatchResultHost;
                } else if (currentBet == firstBetValue) {
                    currentBet = 0;
                } else {
                    currentBet--;
                }
                break;
            case 1: // Draw
                if (result == FTBMatchResultDraw) {
                    currentBet++;
                } else if (currentBet == 0) {
                    currentBet = firstBetValue;
                    result = FTBMatchResultDraw;
                } else if (currentBet == firstBetValue) {
                    currentBet = 0;
                } else {
                    currentBet--;
                }
                break;
            case 2: // Guest
                if (result == FTBMatchResultGuest) {
                    currentBet++;
                } else if (currentBet == 0) {
                    currentBet = firstBetValue;
                    result = FTBMatchResultGuest;
                } else if (currentBet == firstBetValue) {
                    currentBet = 0;
                } else {
                    currentBet--;
                }
                break;
        }
        
        if (10 * currentBet > weakSelf.challengedUser.funds.integerValue) {
            return;
        }
        
        if (currentBet == 0) {
            result = FTBMatchResultUnknown;
        }
        
        if (weakSelf.bid.integerValue < currentBet && user.funds.integerValue <= 0) {
            if (!weakCell.isStepperSelected) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Error: insufient funds", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
                [alert show];
            }
            return;
        }
        
        if (weakSelf.bid.integerValue < currentBet && user.funds.integerValue < 1 && weakCell.isStepperSelected) {
            weakCell.stepperUserInteractionEnabled = NO;
        }
        
        weakSelf.result = result;
        weakSelf.bid = @(currentBet);
        
        [weakSelf reloadWallet];
        [weakSelf configureCell:[weakSelf.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
    }];
}

- (void)reloadWallet {
    FTBUser *user = [FTBUser currentUser];
    
    self.navigationBarTitleView.walletValueLabel.text = user.wallet.limitedWalletStringValue;
    self.navigationBarTitleView.stakeValueLabel.text = @(user.stake.floatValue + self.bid.floatValue).limitedWalletStringValue;
    self.navigationBarTitleView.returnValueLabel.text = @(user.toReturn.floatValue + 2 * self.bid.floatValue).stringValue;
    self.navigationBarTitleView.profitValueLabel.text = user.profitString;
    
    if (user.canRecharge) {
        UIImage *rechargeImage = [UIImage imageNamed:@"btn_recharge_money"];
        if ([self.navigationBarTitleView.moneyButton imageForState:UIControlStateNormal] != rechargeImage) {
            [self.navigationBarTitleView.moneyButton setImage:rechargeImage forState:UIControlStateNormal];
        }
    } else {
        [self.navigationBarTitleView.moneyButton setImage:[UIImage imageNamed:@"money_sign"] forState:UIControlStateNormal];
    }
}

- (BOOL)isChallenging {
    return (self.challengedUser != nil);
}

#pragma mark - Actions

- (void)doneAction:(UIButton *)sender {
    [[LoadingHelper sharedInstance] showHud];
    
    __weak typeof(self) weakSelf = self;
    [[FTBClient client] createChallengeForMatch:self.match bid:self.bid result:self.result user:self.challengedUser success:^(id object) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf.challengedUser = nil;
        [strongSelf.navigationBarTitleView removeFromSuperview];
        strongSelf.navigationBarTitleView = nil;
        strongSelf.tableView.contentInset = UIEdgeInsetsZero;
        [strongSelf.tableView reloadData];
        
        [UIView animateWithDuration:0.25 animations:^{
            strongSelf.doneButton.y = strongSelf.view.height;
        } completion:^(BOOL finished) {
            [strongSelf.doneButton removeFromSuperview];
            strongSelf.doneButton = nil;
        }];
        
        [[LoadingHelper sharedInstance] hideHud];
    } failure:^(NSError *error) {
        [[ErrorHandler sharedInstance] displayError:error];
        [[LoadingHelper sharedInstance] hideHud];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.isChallenging ? 1 : 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = indexPath.row == 0 ? @"MatchCell" : @"ChallengeStatusTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 0 ? 340 : 150;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return FLT_EPSILON;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ((FootblTabBarController *)self.tabBarController).tabBarHidden = YES;
    self.view.backgroundColor = [UIColor ftb_viewMatchBackgroundColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.allowsSelection = NO;
    [self.tableView registerClass:[MatchTableViewCell class] forCellReuseIdentifier:@"MatchCell"];
    [self.tableView registerNib:[ChallengeStatusTableViewCell nib] forCellReuseIdentifier:@"ChallengeStatusTableViewCell"];
    [self.view addSubview:self.tableView];
    
    self.navigationBarTitleView = [[MatchesNavigationBarView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, 60)];
    self.navigationBarTitleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.navigationBarTitleView];
    
    if (self.isChallenging) {
        self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.doneButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
        self.doneButton.backgroundColor = [UIColor ftb_greenGrassColor];
        self.doneButton.size = CGSizeMake(self.view.width, 49);
        self.doneButton.maxY = self.view.height;
        [self.view addSubview:self.doneButton];
    }
    
    [self reloadWallet];
}

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Challenge!", nil);
    }
    return self;
}

@end
