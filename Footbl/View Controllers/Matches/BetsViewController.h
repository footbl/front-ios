//
//  BetsViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 7/10/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateViewController.h"

@class MatchesNavigationBarView;

@interface BetsViewController : TemplateViewController

@property (strong, nonatomic) NSArray *championships;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) MatchesNavigationBarView *navigationBarTitleView;;
@property (strong, nonatomic) UILabel *placeholderLabel;

- (void)reloadWallet;
- (IBAction)rechargeWalletAction:(id)sender;

@end
