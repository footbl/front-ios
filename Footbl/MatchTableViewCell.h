//
//  MatchTableViewCell.h
//  Footbl
//
//  Created by Fernando Saragoça on 3/27/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TemplateTableViewCell.h"

@class TeamImageView;

typedef NS_ENUM(NSInteger, MatchTableViewCellLayout) {
    MatchTableViewCellLayoutNoBet,
    MatchTableViewCellLayoutHost,
    MatchTableViewCellLayoutDraw,
    MatchTableViewCellLayoutGuest
};

@interface MatchTableViewCell : TemplateTableViewCell

@property (assign, nonatomic) MatchTableViewCellLayout layout;
@property (strong, nonatomic) UIView *cardContentView;
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
@property (strong, nonatomic) UILabel *hostNameLabel;
@property (strong, nonatomic) UILabel *hostPotLabel;
@property (strong, nonatomic) TeamImageView *hostImageView;
// Draw
@property (strong, nonatomic) UILabel *drawLabel;
@property (strong, nonatomic) UILabel *drawPotLabel;
@property (strong, nonatomic) UILabel *versusLabel;
// Guest
@property (strong, nonatomic) UILabel *guestNameLabel;
@property (strong, nonatomic) UILabel *guestPotLabel;
@property (strong, nonatomic) TeamImageView *guestImageView;
// Footer
@property (strong, nonatomic) UILabel *footerLabel;

- (void)setStakesCount:(NSNumber *)stakesCount commentsCount:(NSNumber *)commentsCount;
- (void)setDateText:(NSString *)dateText;

@end
