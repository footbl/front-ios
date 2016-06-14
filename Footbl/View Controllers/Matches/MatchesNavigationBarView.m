//
//  MatchesNavigationBarView.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/23/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "MatchesNavigationBarView.h"
#import "ChampionshipsHeaderView.h"
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
        self.backgroundColor = [UIColor ftb_navigationBarColor];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSMutableDictionary *titleAttributes = [@{NSForegroundColorAttributeName : [UIColor ftb_greenMoneyColor],
                                                  NSParagraphStyleAttributeName : paragraphStyle,
                                                  NSFontAttributeName : [UIFont fontWithName:kFontNameMedium size:12],
                                                  NSKernAttributeName : @(-0.15)} mutableCopy];
        
        self.walletValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, self.height - 55, 48, 35)];
        self.walletValueLabel.textColor = [UIColor ftb_greenMoneyColor];
        self.walletValueLabel.font = [UIFont fontWithName:kFontNameMedium size:self.defaultValueFontSize];
        self.walletValueLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.walletValueLabel];
        
        self.walletTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, self.height - 22, 72, 14)];
        self.walletTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Wallet", @"") attributes:titleAttributes];
        [self addSubview:self.walletTitleLabel];
        
        UIImage *image = [UIImage imageNamed:@"money_sign"];
        self.moneyButton = [RechargeButton buttonWithType:UIButtonTypeCustom];
        [self.moneyButton setImage:image forState:UIControlStateNormal];
        self.moneyButton.size = image.size;
        self.moneyButton.midY = self.walletValueLabel.midY;
        self.moneyButton.midX = self.walletValueLabel.x / 2;
        self.moneyButton.adjustsImageWhenDisabled = NO;
        [self addSubview:self.moneyButton];
        
        titleAttributes[NSForegroundColorAttributeName] = [UIColor ftb_redStakeColor];
        
        CGFloat stakeWidth = 72 + (CGRectGetWidth(frame) - 320) * 0.4;
        
        self.stakeValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(93 + (CGRectGetWidth(frame) - 320) * 0.15, self.height - 55, stakeWidth, 35)];
        self.stakeValueLabel.textColor = [UIColor ftb_redStakeColor];
        self.stakeValueLabel.font = [UIFont fontWithName:kFontNameMedium size:self.defaultValueFontSize];
        self.stakeValueLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.stakeValueLabel];
        
        self.stakeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(91 + (CGRectGetWidth(frame) - 320) * 0.15, self.height - 22, stakeWidth, 14)];
        self.stakeTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Stake", @"") attributes:titleAttributes];
        [self addSubview:self.stakeTitleLabel];
        
        titleAttributes[NSForegroundColorAttributeName] = [UIColor ftb_blueReturnColor];
        
        self.returnValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(159 + (CGRectGetWidth(frame) - 320) * 0.5, self.height - 55, stakeWidth, 35)];
        self.returnValueLabel.textColor = [UIColor ftb_blueReturnColor];
        self.returnValueLabel.font = [UIFont fontWithName:kFontNameMedium size:self.defaultValueFontSize];
        self.returnValueLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.returnValueLabel];
        
        self.returnTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(159 + (CGRectGetWidth(frame) - 320) * 0.5, self.height - 22, stakeWidth, 14)];
        self.returnTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"To return", @"") attributes:titleAttributes];
        [self addSubview:self.returnTitleLabel];
        
        titleAttributes[NSForegroundColorAttributeName] = [UIColor ftb_greenMoneyColor];
        
        self.profitValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) - 80, self.height - 55, 72, 35)];
        self.profitValueLabel.textColor = [UIColor ftb_greenMoneyColor];
        self.profitValueLabel.font = [UIFont fontWithName:kFontNameMedium size:self.defaultValueFontSize];
        self.profitValueLabel.textAlignment = NSTextAlignmentCenter;
        self.profitValueLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:self.profitValueLabel];
        
        self.profitTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) - 81, self.height - 22, 72, 14)];
        self.profitTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Profit", @"") attributes:titleAttributes];
        self.profitTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:self.profitTitleLabel];
    }
    return self;
}

- (CGFloat)defaultValueFontSize {
    return 24.f;
}

- (void)setTitleHidden:(BOOL)titleHidden animated:(BOOL)animated {
    if (_titleHidden == titleHidden || self.isHidden) {
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
        
        self.height = titleHidden ? 64 : 80;
        self.championshipsHeaderView.y = self.height;
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
