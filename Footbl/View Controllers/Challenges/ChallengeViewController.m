//
//  ChallengeViewController.m
//  Footbl
//
//  Created by Leonardo Formaggio on 5/2/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

#import "ChallengeViewController.h"
#import "ChallengeStatusTableViewCell.h"
#import "FootblTabBarController.h"
#import "FTBChallenge.h"
#import "FTBClient.h"
#import "FTBMatch.h"
#import "FTBUser.h"
#import "LoadingHelper.h"
#import "MatchesNavigationBarView.h"
#import "MatchTableViewCell+Setup.h"
#import "MatchTableViewCell.h"
#import "NSNumber+Formatter.h"
#import "RechargeButton.h"
#import "UIFont+MaxFontSize.h"
#import "UIView+Frame.h"

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
    } else if (self.challenge.status == FTBChallengeStatusRejected) {
        cell.statusLabel.font = [cell.statusLabel.font fontWithSize:17];
        cell.statusLabel.textColor = [UIColor ftb_redStakeColor];
        cell.statusLabel.text = NSLocalizedString(@"Challenge declined!", nil);
        cell.substatusLabel.textColor = [UIColor lightGrayColor];
        cell.substatusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"$%@ returned to your wallet", nil), self.challenge.bid];
    } else if (self.challenge.status == FTBChallengeStatusWaiting && !self.challenge.sender.isMe) {
        cell.statusLabel.text = nil;
        cell.substatusLabel.text = nil;
    } else if (self.challenge.status == FTBChallengeStatusWaiting) {
        cell.statusLabel.font = [cell.statusLabel.font fontWithSize:17];
        cell.statusLabel.textColor = [UIColor lightGrayColor];
        cell.statusLabel.text = NSLocalizedString(@"Waiting for opponent", nil);
        cell.substatusLabel.text = nil;
    } else if (self.challenge.status == FTBChallengeStatusAccepted && !self.challenge.match.started) {
        cell.statusLabel.font = [cell.statusLabel.font fontWithSize:17];
        cell.statusLabel.textColor = [UIColor ftb_greenGrassColor];
        cell.statusLabel.text = NSLocalizedString(@"Challenge accepted!", nil);
        cell.substatusLabel.text = nil;
    } else if (self.challenge.status == FTBChallengeStatusAccepted && self.challenge.match.finished && self.challenge.myResult != self.challenge.match.result && self.challenge.oponentResult != self.challenge.match.result) {
        cell.statusLabel.font = [cell.statusLabel.font fontWithSize:17];
        cell.statusLabel.textColor = [UIColor lightGrayColor];
        cell.statusLabel.text = NSLocalizedString(@"No winner", nil);
        cell.substatusLabel.textColor = [UIColor lightGrayColor];
        cell.substatusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"$%@ returned to your wallet", nil), self.challenge.bid];
    } else if (self.challenge.status == FTBChallengeStatusAccepted && self.challenge.match.finished && self.challenge.myResult == self.challenge.match.result && self.challenge.oponentResult != self.challenge.match.result) {
        cell.statusLabel.font = [cell.statusLabel.font fontWithSize:42];
        cell.statusLabel.textColor = [UIColor ftb_blueReturnColor];
        cell.statusLabel.text = NSLocalizedString(@"You WIN!", nil);
        cell.substatusLabel.text = nil;
    } else if (self.challenge.status == FTBChallengeStatusAccepted && self.challenge.match.finished && self.challenge.myResult != self.challenge.match.result && self.challenge.oponentResult == self.challenge.match.result) {
        cell.statusLabel.font = [cell.statusLabel.font fontWithSize:42];
        cell.statusLabel.textColor = [UIColor ftb_redStakeColor];
        cell.statusLabel.text = NSLocalizedString(@"You LOSE!", nil);
        cell.substatusLabel.text = nil;
    } else {
        cell.statusLabel.text = nil;
        cell.substatusLabel.text = nil;
    }
}

- (void)configureMatchCell:(MatchTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    
    FTBUser *user = [FTBUser currentUser];
    FTBChallenge *challenge = self.challenge;

    if (!challenge && self.bid) {
        challenge = [[FTBChallenge alloc] init];
        challenge.sender = user;
        challenge.bid = self.bid;
        challenge.senderResult = self.result;
        challenge.match = self.match;
    }

    FTBMatch *match = challenge.match ?: self.match;
    
    [cell setMatch:match challenge:challenge viewController:self selectionBlock:^(NSInteger index) {
        if (weakSelf.isChallenging) {
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
        } else {
            FTBMatchResult previousResult = weakSelf.challenge.recipientResult;
            FTBMatchResult result = FTBMatchResultUnknown;
            if (index == 0) {
                result = FTBMatchResultHost;
            } else if (index == 1) {
                result = FTBMatchResultDraw;
            } else if (index == 2) {
                result = FTBMatchResultGuest;
            }

            if (result != previousResult) {
                if (result != weakSelf.challenge.senderResult) {
                    weakSelf.challenge.recipientResult = result;
                    [weakSelf setAcceptButtonVisible:YES completion:nil];
                }
            } else {
                weakSelf.challenge.recipientResult = FTBMatchResultUnknown;
                [weakSelf setDeclineButtonVisible:YES completion:nil];
            }

            [weakSelf configureCell:[weakSelf.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
        }
    }];

    if (self.isBeingChallenged) {
        cell.simpleSelection = NO;
    } else if (!self.isChallenging) {
        cell.selectionBlock = nil;
    }
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

- (BOOL)isBeingChallenged {
    return !self.challenge.sender.isMe && self.challenge.status == FTBChallengeStatusWaiting;
}

- (void)setAcceptButtonVisible:(BOOL)visible completion:(void (^)(void))completion {
    void (^animation)() = ^{
        self.acceptButton.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            if (visible) {
                self.acceptButton.maxY = self.view.height;
            } else {
                self.acceptButton.y = self.view.height;
            }
        } completion:^(BOOL finished) {
            self.acceptButton.hidden = !visible;
            if (completion) completion();
        }];
    };

    if (self.declineButton.hidden) {
        animation();
    } else {
        [self setDeclineButtonVisible:NO completion:^{
            animation();
        }];
    }
}

- (void)setDeclineButtonVisible:(BOOL)visible completion:(void (^)(void))completion {
    void (^animation)() = ^{
        self.declineButton.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            if (visible) {
                self.declineButton.maxY = self.view.height;
            } else {
                self.declineButton.y = self.view.height;
            }
        } completion:^(BOOL finished) {
            self.declineButton.hidden = !visible;
            if (completion) completion();
        }];
    };

    if (self.acceptButton.hidden) {
        animation();
    } else {
        [self setAcceptButtonVisible:NO completion:^{
            animation();
        }];
    }
}

#pragma mark - Actions

- (void)doneAction:(UIButton *)sender {
    [[LoadingHelper sharedInstance] showHud];
    
    __weak typeof(self) weakSelf = self;
    [[FTBClient client] createChallengeForMatch:self.match bid:self.bid result:self.result user:self.challengedUser success:^(id object) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        FTBChallenge *challenge = [[FTBChallenge alloc] init];
        challenge.sender = [FTBUser currentUser];
        challenge.bid = strongSelf.bid;
        challenge.senderResult = strongSelf.result;
        challenge.match = strongSelf.match;
        challenge.status = FTBChallengeStatusWaiting;
        strongSelf.challenge = challenge;

        [UIView animateWithDuration:0.25 animations:^{
            strongSelf.doneButton.y = strongSelf.view.height;
            strongSelf.navigationBarTitleView.maxY = 0;
            strongSelf.tableView.contentInset = UIEdgeInsetsZero;
        } completion:^(BOOL finished) {
            [strongSelf.doneButton removeFromSuperview];
            strongSelf.doneButton = nil;

            [strongSelf.navigationBarTitleView removeFromSuperview];
            strongSelf.navigationBarTitleView = nil;

            strongSelf.challengedUser = nil;

            [strongSelf.tableView reloadData];
        }];
        
        [[LoadingHelper sharedInstance] hideHud];
    } failure:^(NSError *error) {
        [[ErrorHandler sharedInstance] displayError:error];
        [[LoadingHelper sharedInstance] hideHud];
    }];
}

- (void)acceptAction:(id)sender {
    [[LoadingHelper sharedInstance] showHud];
    [[FTBClient client] acceptChallenge:self.challenge success:^(id object) {
        [self setAcceptButtonVisible:NO completion:nil];
        [[LoadingHelper sharedInstance] hideHud];
    } failure:^(NSError *error) {
        [[LoadingHelper sharedInstance] hideHud];
    }];
}

- (void)declineAction:(id)sender {
    [[LoadingHelper sharedInstance] showHud];
    [[FTBClient client] rejectChallenge:self.challenge success:^(id object) {
        [self setDeclineButtonVisible:NO completion:nil];
        [[LoadingHelper sharedInstance] hideHud];
    } failure:^(NSError *error) {
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
    if (indexPath.row == 0) {
        return 340;
    } else if (self.isChallenging) {
        return 0;
    } else {
        return CGRectGetHeight(tableView.frame) - 64 - 340;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return FLT_EPSILON;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor ftb_viewMatchBackgroundColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.allowsSelection = NO;
    [self.tableView registerClass:[MatchTableViewCell class] forCellReuseIdentifier:@"MatchCell"];
    [self.tableView registerNib:[ChallengeStatusTableViewCell nib] forCellReuseIdentifier:@"ChallengeStatusTableViewCell"];
    [self.view addSubview:self.tableView];

    if (self.isChallenging) {
        self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);

        self.navigationBarTitleView = [[MatchesNavigationBarView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, 60)];
        self.navigationBarTitleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:self.navigationBarTitleView];

        self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.doneButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.doneButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
        self.doneButton.titleLabel.font = [UIFont fontWithName:kFontNameMedium size:17];
        self.doneButton.backgroundColor = [UIColor ftb_greenGrassColor];
        self.doneButton.size = CGSizeMake(self.view.width, 49);
        self.doneButton.maxY = self.view.height;
        [self.view addSubview:self.doneButton];

        [self reloadWallet];
    } else if (!self.challenge.sender.isMe && self.challenge.status == FTBChallengeStatusWaiting) {
        self.declineButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.declineButton addTarget:self action:@selector(declineAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.declineButton setTitle:NSLocalizedString(@"Decline", nil) forState:UIControlStateNormal];
        self.declineButton.titleLabel.font = [UIFont fontWithName:kFontNameMedium size:17];
        self.declineButton.backgroundColor = [UIColor ftb_redStakeColor];
        self.declineButton.size = CGSizeMake(self.view.width, 49);
        self.declineButton.maxY = self.view.height;
        [self.view addSubview:self.declineButton];

        self.acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.acceptButton addTarget:self action:@selector(acceptAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.acceptButton setTitle:NSLocalizedString(@"Accept", nil) forState:UIControlStateNormal];
        self.acceptButton.titleLabel.font = [UIFont fontWithName:kFontNameMedium size:17];
        self.acceptButton.backgroundColor = [UIColor ftb_greenMoneyColor];
        self.acceptButton.size = CGSizeMake(self.view.width, 49);
        self.acceptButton.y = self.view.height;
        self.acceptButton.hidden = YES;
        [self.view addSubview:self.acceptButton];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [(FootblTabBarController *)self.tabBarController setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [(FootblTabBarController *)self.tabBarController setTabBarHidden:NO animated:YES];
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
