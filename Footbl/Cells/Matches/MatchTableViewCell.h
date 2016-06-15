//
//  MatchTableViewCell.h
//  Footbl
//
//  Created by Fernando Saragoça on 3/27/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateTableViewCell.h"

@class TeamImageView;
@class UserImageView;

typedef NS_ENUM(NSInteger, MatchTableViewCellLayout) {
    MatchTableViewCellLayoutNoBet,
    MatchTableViewCellLayoutHost,
    MatchTableViewCellLayoutDraw,
    MatchTableViewCellLayoutGuest
};

typedef NS_ENUM(NSInteger, MatchTableViewCellStateLayout) {
    MatchTableViewCellStateLayoutWaiting,
    MatchTableViewCellStateLayoutLive,
    MatchTableViewCellStateLayoutDone
};

typedef NS_ENUM(NSInteger, MatchTableViewCellColorScheme) {
    MatchTableViewCellColorSchemeDefault,
    MatchTableViewCellColorSchemeHighlightProfit,
    MatchTableViewCellColorSchemeGray
};

@interface MatchTableViewCell : TemplateTableViewCell

@property (assign, nonatomic) MatchTableViewCellLayout layout;
@property (assign, nonatomic) MatchTableViewCellStateLayout stateLayout;
@property (copy, nonatomic) void (^selectionBlock)(NSInteger index);
@property (copy, nonatomic) void (^shareBlock)(MatchTableViewCell *matchCell);
@property (strong, nonatomic) UIView *cardContentView;
@property (assign, nonatomic, getter = isStepperUserInteractionEnabled) BOOL stepperUserInteractionEnabled;
@property (assign, nonatomic) MatchTableViewCellColorScheme colorScheme;
@property (assign, nonatomic) BOOL simpleSelection;

// Live
@property (strong, nonatomic) UIView *liveHeaderView;
@property (strong, nonatomic) UILabel *liveLabel;
// Date
@property (strong, nonatomic) UILabel *dateLabel;
// Bet
@property (strong, nonatomic) UILabel *stakeTitleLabel;
@property (strong, nonatomic) UILabel *stakeValueLabel;
@property (strong, nonatomic) UILabel *returnTitleLabel;
@property (strong, nonatomic) UILabel *returnValueLabel;
@property (strong, nonatomic) UILabel *profitTitleLabel;
@property (strong, nonatomic) UILabel *profitValueLabel;

// Host
@property (strong, nonatomic) UILabel *hostScoreLabel;
@property (strong, nonatomic) UILabel *hostNameLabel;
@property (strong, nonatomic) UILabel *hostPotLabel;
@property (strong, nonatomic) TeamImageView *hostImageView;
@property (strong, nonatomic) UserImageView *hostUserImageView;
@property (strong, nonatomic) UIStepper *hostStepper;

// Draw
@property (strong, nonatomic) UILabel *drawLabel;
@property (strong, nonatomic) UILabel *drawPotLabel;
@property (strong, nonatomic) UILabel *versusLabel;
@property (strong, nonatomic) UserImageView *drawUserImageView;
@property (strong, nonatomic) UIStepper *drawStepper;

// Guest
@property (strong, nonatomic) UILabel *guestScoreLabel;
@property (strong, nonatomic) UILabel *guestNameLabel;
@property (strong, nonatomic) UILabel *guestPotLabel;
@property (strong, nonatomic) TeamImageView *guestImageView;
@property (strong, nonatomic) UserImageView *guestUserImageView;
@property (strong, nonatomic) UIStepper *guestStepper;

// Footer
@property (strong, nonatomic) UILabel *footerLabel;
@property (strong, nonatomic) UIButton *shareButton;

@property (strong, nonatomic) UITapGestureRecognizer *guestImageViewGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *hostImageViewGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *versusLabelGestureRecognizer;


- (CGFloat)defaultTeamNameFontSize;
- (void)setDateText:(NSString *)dateText;
- (void)setFooterText:(NSString *)footerText;
- (UIImage *)imageRepresentation;
- (BOOL)isStepperSelected;

@end
