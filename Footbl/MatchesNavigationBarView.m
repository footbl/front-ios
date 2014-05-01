//
//  MatchesNavigationBarView.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/23/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "MatchesNavigationBarView.h"

#pragma mark MatchesNavigationBarView

@implementation MatchesNavigationBarView

#pragma mark - Getters/Setters

- (void)setTitleHidden:(BOOL)titleHidden {
    [self setTitleHidden:titleHidden animated:NO];
}

#pragma mark - Instance Methods

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [FootblAppearance colorForView:FootblColorNavigationBar];
        self.clipsToBounds = NO;
        
        self.separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(frame), CGRectGetWidth(frame), 0.5)];
        self.separatorView.backgroundColor = [FootblAppearance colorForView:FootblColorNavigationBarSeparator];
        self.separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.separatorView];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSMutableDictionary *titleAttributes = [@{NSForegroundColorAttributeName : [UIColor ftGreenMoneyColor],
                                                  NSParagraphStyleAttributeName : paragraphStyle,
                                                  NSFontAttributeName : [UIFont fontWithName:kFontNameMedium size:12],
                                                  NSKernAttributeName : @(-0.15)} mutableCopy];
        
        self.moneyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 102, CGRectGetHeight(self.frame))];
        [self.moneyButton setImage:[UIImage imageNamed:@"money_sign"] forState:UIControlStateNormal];
        [self.moneyButton setImageEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 62)];
        self.moneyButton.enabled = NO;
        self.moneyButton.adjustsImageWhenDisabled = NO;
        [self addSubview:self.moneyButton];
        
        self.walletValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 30, 42, 25)];
        self.walletValueLabel.textColor = [UIColor ftGreenMoneyColor];
        self.walletValueLabel.font = [UIFont fontWithName:kFontNameMedium size:24];
        self.walletValueLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.walletValueLabel];
        
        self.walletTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 58 , 72, 14)];
        self.walletTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Wallet", @"") attributes:titleAttributes];
        [self addSubview:self.walletTitleLabel];
        
        titleAttributes[NSForegroundColorAttributeName] = [UIColor ftRedStakeColor];
        
        self.stakeValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(93, 30, 72, 25)];
        self.stakeValueLabel.textColor = [UIColor ftRedStakeColor];
        self.stakeValueLabel.font = [UIFont fontWithName:kFontNameMedium size:24];
        self.stakeValueLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.stakeValueLabel];
        
        self.stakeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(91, 58, 72, 14)];
        self.stakeTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Stake", @"") attributes:titleAttributes];
        [self addSubview:self.stakeTitleLabel];
        
        titleAttributes[NSForegroundColorAttributeName] = [UIColor ftBlueReturnColor];
        
        self.returnValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(159, 30, 72, 25)];
        self.returnValueLabel.textColor = [UIColor ftBlueReturnColor];
        self.returnValueLabel.font = [UIFont fontWithName:kFontNameMedium size:24];
        self.returnValueLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.returnValueLabel];
        
        self.returnTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 58, 72, 14)];
        self.returnTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"To return", @"") attributes:titleAttributes];
        [self addSubview:self.returnTitleLabel];
        
        titleAttributes[NSForegroundColorAttributeName] = [UIColor ftGreenMoneyColor];
        
        self.profitValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(242, 30, 72, 25)];
        self.profitValueLabel.textColor = [UIColor ftGreenMoneyColor];
        self.profitValueLabel.font = [UIFont fontWithName:kFontNameMedium size:24];
        self.profitValueLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.profitValueLabel];
        
        self.profitTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(242, 58, 72, 14)];
        self.profitTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Profit", @"") attributes:titleAttributes];
        [self addSubview:self.profitTitleLabel];
        
        for (NSNumber *offsetX in @[@77.5, @242]) {
            UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(offsetX.floatValue, 27, 0.5, 29)];
            separatorView.backgroundColor = [FootblAppearance colorForView:FootblColorNavigationBarSeparator];
            [self addSubview:separatorView];
        }
    }
    return self;
}

- (void)setTitleHidden:(BOOL)titleHidden animated:(BOOL)animated {
    if (_titleHidden == titleHidden) {
        return;
    }
    
    _titleHidden = titleHidden;
    
    NSArray *titleLabels = @[self.walletTitleLabel, self.stakeTitleLabel, self.returnTitleLabel, self.profitTitleLabel];
    static CGFloat kTitleLabelAnimationVerticalOffset = -4;
    
    CGFloat originalY = CGRectGetMinY(self.walletTitleLabel.frame);
    if (!titleHidden) {
        for (UILabel *label in titleLabels) {
            CGRect frame = label.frame;
            frame.origin.y = originalY + kTitleLabelAnimationVerticalOffset;
            label.frame = frame;
        }
    }
    
    [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] animations:^{
        for (UILabel *label in titleLabels) {
            CGRect labelFrame = label.frame;
            labelFrame.origin.y = originalY + (titleHidden ? kTitleLabelAnimationVerticalOffset : 0);
            label.frame = labelFrame;
            label.alpha = titleHidden ? 0 : 1;
        }
        
        CGRect frame = self.frame;
        frame.size.height = titleHidden ? 64 : 80;
        self.frame = frame;
        
        CGRect separatorFrame = self.separatorView.frame;
        separatorFrame.origin.y = CGRectGetMaxY(frame);
        self.separatorView.frame = separatorFrame;
    } completion:^(BOOL finished) {
        for (UILabel *label in titleLabels) {
            CGRect frame = label.frame;
            frame.origin.y = originalY;
            label.frame = frame;
        }
    }];
}

@end
