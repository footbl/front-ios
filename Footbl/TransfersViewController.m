//
//  TransfersViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/29/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "FootblTabBarController.h"
#import "NSParagraphStyle+AlignmentCenter.h"
#import "TransfersViewController.h"
#import "UIImage+Color.h"
#import "User.h"
#import "Wallet.h"

@interface TransfersViewController ()

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
    
    [walletText appendAttributedString:[[NSAttributedString alloc] initWithString:[[User currentUser].localFunds.stringValue stringByAppendingString:@"\n"] attributes:textAttributes]];
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

#pragma mark - Delegates & Data sources

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Transfers", @"");
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    self.view.clipsToBounds = NO;
    
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
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(headerView.frame) - 66)];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.rowHeight = 62;
    self.tableView.separatorColor = separatorView.backgroundColor;
    [self.view insertSubview:self.tableView belowSubview:separatorView];
    
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 66, CGRectGetWidth(self.view.frame), 66)];
    self.sendButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.sendButton.titleLabel.font = [UIFont fontWithName:kFontNameMedium size:19];
    [self.sendButton setTitle:NSLocalizedString(@"Send $", @"") forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0.21 green:0.78 blue:0.46 alpha:1]] forState:UIControlStateNormal];
    [self.view addSubview:self.sendButton];
    
    [self setupLabels];
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
