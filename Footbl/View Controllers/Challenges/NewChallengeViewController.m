//
//  NewChallengeViewController.m
//  Footbl
//
//  Created by Leonardo Formaggio on 5/2/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import "NewChallengeViewController.h"
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

@implementation NewChallengeViewController

#pragma mark - Instance Methods

- (void)configureCell:(MatchTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    
    [cell setMatch:self.match challenge:self.challenge viewController:self selectionBlock:^(NSInteger index) {
        FTBUser *user = [FTBUser currentUser];
        NSUInteger firstBetValue = MAX(floor((user.funds.integerValue + user.stake.integerValue) / 100), 1);
        NSInteger currentBet = weakSelf.challenge.bid.integerValue;
        FTBMatchResult result = weakSelf.challenge.challengerResult;
        
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
        
        if (weakSelf.challenge.bid.integerValue < currentBet && (user.funds.integerValue - 1) < 0) {
            if (!weakCell.isStepperSelected) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Error: insufient funds", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
                [alert show];
            }
            return;
        }
        
        if (weakSelf.challenge.bid.integerValue < currentBet && user.funds.integerValue < 1 && weakCell.isStepperSelected) {
            weakCell.stepperUserInteractionEnabled = NO;
        }
        
        [weakSelf reloadWallet];
        [weakSelf configureCell:[weakSelf.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
    } ];
}

- (void)reloadWallet {
    NSArray *labels = @[self.navigationBarTitleView.walletValueLabel,
                        self.navigationBarTitleView.stakeValueLabel,
                        self.navigationBarTitleView.returnValueLabel,
                        self.navigationBarTitleView.profitValueLabel];
    
    FTBUser *user = [FTBUser currentUser];
    if (user) {
        [UIView animateWithDuration:FTBAnimationDuration animations:^{
            for (UILabel *label in labels) {
                label.alpha = 1;
            }
        }];
        self.navigationBarTitleView.walletValueLabel.text = user.wallet.limitedWalletStringValue;
        self.navigationBarTitleView.stakeValueLabel.text = user.stake.limitedWalletStringValue;
        self.navigationBarTitleView.returnValueLabel.text = user.toReturnString;
        self.navigationBarTitleView.profitValueLabel.text = user.profitString;
    } else {
        for (UILabel *label in labels) {
            label.text = @"";
            label.alpha = 0;
        }
    }
    
    if (user.canRecharge) {
        UIImage *rechargeImage = [UIImage imageNamed:@"btn_recharge_money"];
        if ([self.navigationBarTitleView.moneyButton imageForState:UIControlStateNormal] != rechargeImage) {
            [self.navigationBarTitleView.moneyButton setImage:rechargeImage forState:UIControlStateNormal];
        }
    } else {
        [self.navigationBarTitleView.moneyButton setImage:[UIImage imageNamed:@"money_sign"] forState:UIControlStateNormal];
    }
    
    [UIFont setMaxFontSizeToFitBoundsInLabels:labels];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MatchTableViewCell *cell = (MatchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MatchCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 340;
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
    self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(60, 0, 0, 0);
    [self.tableView registerClass:[MatchTableViewCell class] forCellReuseIdentifier:@"MatchCell"];
    [self.view addSubview:self.tableView];
    
    self.navigationBarTitleView = [[MatchesNavigationBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 60)];
    self.navigationBarTitleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.navigationBarTitleView];
    
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
