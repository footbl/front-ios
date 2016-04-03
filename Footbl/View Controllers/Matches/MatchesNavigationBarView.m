//
//  MatchesNavigationBarView.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/23/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "MatchesNavigationBarView.h"
#import "RechargeButton.h"
#import "UIView+Frame.h"

#pragma mark MatchesNavigationBarView

@implementation MatchesNavigationBarView

NSString * const kMatchesNavigationBarTitleAnimateKey = @"kMatchesNavigationBarTitleAnimateKey";

#pragma mark - Getters/Setters

- (void)setTitleHidden:(BOOL)titleHidden {
    [self setTitleHidden:titleHidden animated:NO];
}

#pragma mark - Instance Methods

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor ftb_navigationBarColor];
        self.clipsToBounds = NO;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSMutableDictionary *titleAttributes = [@{NSForegroundColorAttributeName : [UIColor ftb_greenMoneyColor],
                                                  NSParagraphStyleAttributeName : paragraphStyle,
                                                  NSFontAttributeName : [UIFont fontWithName:kFontNameMedium size:12],
                                                  NSKernAttributeName : @(-0.15)} mutableCopy];
        
        self.moneyButton = [[RechargeButton alloc] initWithFrame:CGRectMake(0, 0, 102, self.height - 30)];
        [self.moneyButton setImage:[UIImage imageNamed:@"money_sign"] forState:UIControlStateNormal];
        [self.moneyButton setImageEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 62)];
        self.moneyButton.adjustsImageWhenDisabled = NO;
        [self addSubview:self.moneyButton];
        
        self.walletValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 25, 48, 35)];
        self.walletValueLabel.textColor = [UIColor ftb_greenMoneyColor];
        self.walletValueLabel.font = [UIFont fontWithName:kFontNameMedium size:self.defaultValueFontSize];
        self.walletValueLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.walletValueLabel];
        
        self.walletTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 58 , 72, 14)];
        self.walletTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Wallet", @"") attributes:titleAttributes];
        [self addSubview:self.walletTitleLabel];
        
        titleAttributes[NSForegroundColorAttributeName] = [UIColor ftb_redStakeColor];
        
        CGFloat stakeWidth = 72 + (CGRectGetWidth(frame) - 320) * 0.4;
        
        self.stakeValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(93 + (CGRectGetWidth(frame) - 320) * 0.15, 25, stakeWidth, 35)];
        self.stakeValueLabel.textColor = [UIColor ftb_redStakeColor];
        self.stakeValueLabel.font = [UIFont fontWithName:kFontNameMedium size:self.defaultValueFontSize];
        self.stakeValueLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.stakeValueLabel];
        
        self.stakeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(91 + (CGRectGetWidth(frame) - 320) * 0.15, 58, stakeWidth, 14)];
        self.stakeTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Stake", @"") attributes:titleAttributes];
        [self addSubview:self.stakeTitleLabel];
        
        titleAttributes[NSForegroundColorAttributeName] = [UIColor ftb_blueReturnColor];
        
        self.returnValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(159 + (CGRectGetWidth(frame) - 320) * 0.5, 25, stakeWidth, 35)];
        self.returnValueLabel.textColor = [UIColor ftb_blueReturnColor];
        self.returnValueLabel.font = [UIFont fontWithName:kFontNameMedium size:self.defaultValueFontSize];
        self.returnValueLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.returnValueLabel];
        
        self.returnTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(159 + (CGRectGetWidth(frame) - 320) * 0.5, 58, stakeWidth, 14)];
        self.returnTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"To return", @"") attributes:titleAttributes];
        [self addSubview:self.returnTitleLabel];
        
        titleAttributes[NSForegroundColorAttributeName] = [UIColor ftb_greenMoneyColor];
        
        self.profitValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) - 80, 25, 72, 35)];
        self.profitValueLabel.textColor = [UIColor ftb_greenMoneyColor];
        self.profitValueLabel.font = [UIFont fontWithName:kFontNameMedium size:self.defaultValueFontSize];
        self.profitValueLabel.textAlignment = NSTextAlignmentCenter;
        self.profitValueLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:self.profitValueLabel];
        
        self.profitTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) - 81, 58, 72, 14)];
        self.profitTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Profit", @"") attributes:titleAttributes];
        self.profitTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:self.profitTitleLabel];
        
        UIView *leftSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(89.5, 27, 0.5, 29)];
        leftSeparatorView.backgroundColor = [UIColor ftb_navigationBarSeparatorColor];
        [self addSubview:leftSeparatorView];
        
        UIView *rightSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) - 85, 27, 0.5, 29)];
        rightSeparatorView.backgroundColor = [UIColor ftb_navigationBarSeparatorColor];
        rightSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:rightSeparatorView];
        
        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 30, self.width, 30)];
        self.headerView.backgroundColor = [UIColor clearColor];
        self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.headerView];
        
        self.headerLabel = [[UILabel alloc] initWithFrame:self.headerView.bounds];
        self.headerLabel.font = [UIFont fontWithName:kFontNameMedium size:12];
        self.headerLabel.textColor = [UIColor colorWithRed:0.00/255.f green:169/255.f blue:72./255.f alpha:1.00];
        self.headerLabel.textAlignment = NSTextAlignmentCenter;
        [self.headerView addSubview:self.headerLabel];
        
        self.headerSliderBackImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider_tab_back"]];
        self.headerSliderBackImageView.center = CGPointMake(15, self.headerLabel.midY);
        self.headerSliderBackImageView.hidden = YES;
        [self.headerView addSubview:self.headerSliderBackImageView];
        
        self.headerSliderForwardImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider_tab_forward"]];
        self.headerSliderForwardImageView.center = CGPointMake(self.width - 15, self.headerLabel.midY);
        self.headerSliderForwardImageView.hidden = YES;
        [self.headerView addSubview:self.headerSliderForwardImageView];
        
        UIView *bottomSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.headerView.height - 0.5, self.headerView.width, 0.5)];
        bottomSeparatorView.backgroundColor = [UIColor ftb_navigationBarSeparatorColor];
        bottomSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.headerView addSubview:bottomSeparatorView];
        
        UIView *topSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.headerView.width, 0.5)];
        topSeparatorView.backgroundColor = [UIColor ftb_navigationBarSeparatorColor];
        topSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.headerView addSubview:topSeparatorView];
    }
    return self;
}

- (CGFloat)defaultValueFontSize {
    return 24.f;
}

- (void)setTitleHidden:(BOOL)titleHidden animated:(BOOL)animated {
    if (_titleHidden == titleHidden) {
        return;
    }
    
    _titleHidden = titleHidden;
    
    NSArray *titleLabels = @[self.walletTitleLabel, self.stakeTitleLabel, self.returnTitleLabel, self.profitTitleLabel];
    static CGFloat kTitleLabelAnimationVerticalOffset = -4;
    
    CGFloat originalY = 58;
    if (!titleHidden) {
        for (UILabel *label in titleLabels) {
            CGRect frame = label.frame;
            frame.origin.y = originalY + kTitleLabelAnimationVerticalOffset;
            label.frame = frame;
        }
    }
    
    [UIView animateWithDuration:FTBAnimationDuration animations:^{
        for (UILabel *label in titleLabels) {
            CGRect labelFrame = label.frame;
            labelFrame.origin.y = originalY + (titleHidden ? kTitleLabelAnimationVerticalOffset : 0);
            label.frame = labelFrame;
            label.alpha = titleHidden ? 0 : 1;
        }
        
        self.height = titleHidden ? 94 : 110;
        self.headerView.maxY = self.height;
    } completion:^(BOOL finished) {
        for (UILabel *label in titleLabels) {
            CGRect frame = label.frame;
            frame.origin.y = originalY;
            label.frame = frame;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kMatchesNavigationBarTitleAnimateKey object:nil];
    }];
}

@end
