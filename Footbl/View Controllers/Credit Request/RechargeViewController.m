//
//  RechargeViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/29/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "AskFriendsViewController.h"
#import "FootblLabel.h"
#import "NSParagraphStyle+AlignmentCenter.h"
#import "LoadingHelper.h"
#import "RechargeViewController.h"
#import "UIView+Frame.h"

#import "FTBClient.h"
#import "FTBUser.h"

@interface RechargeViewController ()

@end

#pragma mark RechargeViewController

@implementation RechargeViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (IBAction)askFriendsAction:(id)sender {
    [self.navigationController pushViewController:[AskFriendsViewController new] animated:YES];
}

- (IBAction)rechargeAction:(id)sender {
	FTBUser *user = [FTBUser currentUser];
    if (!user.canRecharge) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Ops", @"") message:NSLocalizedString(@"Cannot update wallet due to wallet balance", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [[LoadingHelper sharedInstance] showHud];
	[[FTBClient client] rechargeUser:user.identifier success:^(id object) {
        [[LoadingHelper sharedInstance] hideHud];
        [self dismissViewController];
    } failure:^(NSError *error) {
        SPLogError(@"%@", error);
        [[LoadingHelper sharedInstance] hideHud];
        [[ErrorHandler sharedInstance] displayError:error];
    }];
}

#pragma mark - Delegates & Data sources

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
	
	FTBUser *user = [FTBUser currentUser];
	
    self.navigationController.navigationBarHidden = YES;
    
    self.headerImageView.image = [UIImage imageNamed:@"illust_recharge_money"];
    
    FootblLabel *rechargeLabel = [[FootblLabel alloc] initWithFrame:CGRectMake(30, self.headerImageView.height + 3, self.view.width - 60, 95)];
    rechargeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    rechargeLabel.textColor = [UIColor colorWithRed:156/255.f green:164/255.f blue:158/255.f alpha:1.00];
    rechargeLabel.textAlignment = NSTextAlignmentCenter;
    rechargeLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:15];
    rechargeLabel.firstLineFont = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:18];
    rechargeLabel.firstLineTextColor = [UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:1.00];
    rechargeLabel.text = NSLocalizedString(@"Recharge your wallet\nMake more bets and increase your profit!", @"");
    [self.view addSubview:rechargeLabel];
    
    FootblLabel *walletLabel = [[FootblLabel alloc] initWithFrame:CGRectMake(29, 224, 86, 72)];
    walletLabel.textAlignment = NSTextAlignmentCenter;
    walletLabel.textColor = [UIColor colorWithRed:156/255.f green:164/255.f blue:158/255.f alpha:1.00];
    walletLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:11];
    walletLabel.firstLineFont = [UIFont fontWithName:kFontNameAvenirNextMedium size:36];
    walletLabel.lineHeightMultiple = 0.5;
    walletLabel.text = [user.totalWallet.stringValue stringByAppendingFormat:@"\n%@", NSLocalizedString(@"Actual amount", @"").lowercaseString];
    [self.view addSubview:walletLabel];
    
    FootblLabel *afterRechargeLabel = [[FootblLabel alloc] initWithFrame:CGRectMake(self.view.width - 137, 224, 86, 72)];
    afterRechargeLabel.textAlignment = NSTextAlignmentCenter;
    afterRechargeLabel.textColor = [UIColor colorWithRed:156/255.f green:164/255.f blue:158/255.f alpha:1.00];
    afterRechargeLabel.firstLineTextColor = [UIColor colorWithRed:52./255.f green:206/255.f blue:122/255.f alpha:1.00];
    afterRechargeLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:11];
    afterRechargeLabel.firstLineFont = [UIFont fontWithName:kFontNameAvenirNextMedium size:36];
    afterRechargeLabel.lineHeightMultiple = 0.5;
    afterRechargeLabel.text = [[@100 stringValue] stringByAppendingFormat:@"\n%@", NSLocalizedString(@"After recharge", @"").lowercaseString];
    [self.view addSubview:afterRechargeLabel];
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recharge_arrow"]];
    arrowImageView.center = CGPointMake(CGRectGetMidX(self.view.frame) - 1, 270);
    arrowImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:arrowImageView];
    
    for (NSNumber *y in @[@317, @381, @444]) {
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(8, y.floatValue, self.view.width - 16, 0.5)];
        separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        separatorView.backgroundColor = [UIColor colorWithRed:0.69 green:0.92 blue:0.8 alpha:1];
        [self.view addSubview:separatorView];
    }
    
    UIButton *askFriendsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 317 + 56, self.view.width, 71)];
    askFriendsButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    askFriendsButton.titleLabel.font = [UIFont fontWithName:kFontNameSystemMedium size:16];
    [askFriendsButton setTitle:NSLocalizedString(@"Ask for friends", @"") forState:UIControlStateNormal];
    [askFriendsButton setTitleColor:[UIColor colorWithRed:52./255.f green:206/255.f blue:122/255.f alpha:1.0] forState:UIControlStateNormal];
    [askFriendsButton setTitleColor:[UIColor colorWithRed:52./255.f green:206/255.f blue:122/255.f alpha:0.4] forState:UIControlStateHighlighted];
    [askFriendsButton addTarget:self action:@selector(askFriendsAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:askFriendsButton];
    
    UIButton *purchaseButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 381 + 56, self.view.width, 71)];
    purchaseButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    purchaseButton.titleLabel.font = [UIFont fontWithName:kFontNameSystemMedium size:16];
    [purchaseButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"Buy for %@", @"{recharge value}"), @"$0.99"] forState:UIControlStateNormal];
    [purchaseButton setTitleColor:[UIColor colorWithRed:52./255.f green:206/255.f blue:122/255.f alpha:1.0] forState:UIControlStateNormal];
    [purchaseButton setTitleColor:[UIColor colorWithRed:52./255.f green:206/255.f blue:122/255.f alpha:0.4] forState:UIControlStateHighlighted];
    [purchaseButton addTarget:self action:@selector(rechargeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:purchaseButton];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 444 + 56, self.view.width, 71)];
    cancelButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    cancelButton.titleLabel.font = [UIFont fontWithName:kFontNameSystemMedium size:16];
    [cancelButton setTitle:NSLocalizedString(@"Not now, thank you!", @"") forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor colorWithRed:0.46 green:0.86 blue:0.64 alpha:1.0] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor colorWithRed:0.46 green:0.86 blue:0.64 alpha:0.4] forState:UIControlStateHighlighted];
    [cancelButton addTarget:self action:@selector(dismissViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
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
