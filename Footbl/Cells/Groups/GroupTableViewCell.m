//
//  GroupTableViewCell.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "GroupTableViewCell.h"
#import "UIView+Frame.h"

#pragma mark GroupTableViewCell

@implementation GroupTableViewCell

#pragma mark - Instance Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor ftb_viewMatchBackgroundColor];
        self.contentView.backgroundColor = self.backgroundColor;
        
        self.indicatorView = [[UIView alloc] initWithFrame:CGRectMake(9, 43, 12, 12)];
        self.indicatorView.backgroundColor = [[UIColor ftb_greenGrassColor] colorWithAlphaComponent:0.6];
        self.indicatorView.layer.cornerRadius = CGRectGetHeight(self.indicatorView.frame) / 2;
        self.indicatorView.clipsToBounds = YES;
        [self.contentView addSubview:self.indicatorView];
        
        self.groupImageView = [[UIImageView alloc] initWithFrame:CGRectMake(31, 18, 60, 60)];
        self.groupImageView.backgroundColor = [UIColor whiteColor];
        self.groupImageView.layer.cornerRadius = CGRectGetHeight(self.groupImageView.frame) / 2;
        self.groupImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.groupImageView];
        
        self.unreadCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(81, 56, 24, 24)];
        self.unreadCountLabel.backgroundColor = [UIColor ftb_tabBarTintColor];
        self.unreadCountLabel.layer.cornerRadius = self.unreadCountLabel.height / 2;
        self.unreadCountLabel.clipsToBounds = YES;
        self.unreadCountLabel.textColor = [UIColor whiteColor];
        self.unreadCountLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:13];
        self.unreadCountLabel.textAlignment = NSTextAlignmentCenter;
        self.unreadCountLabel.hidden = YES;
        [self.contentView addSubview:self.unreadCountLabel];
        
        /*
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(107, 19, 220, 22)];
        */
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(107, 0, 220, 96)];
        self.nameLabel.font = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:16];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.textColor = [UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:1.00];
        [self.contentView addSubview:self.nameLabel];
        
        CGRect frame = self.nameLabel.frame;
        frame.origin.y = CGRectGetMaxY(frame) - 1;
        frame.size.height = 20;
        
        self.championshipLabel = [[UILabel alloc] initWithFrame:frame];
        self.championshipLabel.font = [UIFont fontWithName:kFontNameMedium size:14];
        self.championshipLabel.textAlignment = self.nameLabel.textAlignment;
        self.championshipLabel.textColor = [UIColor colorWithRed:141/255.f green:151/255.f blue:144/255.f alpha:1.00];
        [self.contentView addSubview:self.championshipLabel];
        
        frame = self.championshipLabel.frame;
        frame.origin.y = CGRectGetMaxY(frame);
        
        self.roundsLabel = [[UILabel alloc] initWithFrame:frame];
        self.roundsLabel.font = [UIFont fontWithName:self.championshipLabel.font.fontName size:13];
        self.roundsLabel.textAlignment = self.championshipLabel.textAlignment;
        self.roundsLabel.textColor = self.championshipLabel.textColor;
        [self.contentView addSubview:self.roundsLabel];
        
        self.topSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame), 1)];
        self.topSeparatorView.backgroundColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.83 alpha:1];
        self.topSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.topSeparatorView];
        
        self.bottomSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(15, 95.5, CGRectGetWidth(self.contentView.frame) - 15, 0.5)];
        self.bottomSeparatorView.backgroundColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.83 alpha:1];
        self.bottomSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.bottomSeparatorView];
    }
    return self;
}

- (void)setUnreadCount:(NSNumber *)number {
    if (number.integerValue <= 0) {
        self.unreadCountLabel.hidden = YES;
        return;
    }
    
    self.unreadCountLabel.hidden = NO;
    if (number.integerValue >= 20) {
        self.unreadCountLabel.font = [UIFont fontWithName:self.unreadCountLabel.font.familyName size:10];
        self.unreadCountLabel.text = @"20+";
    } else {
        self.unreadCountLabel.font = [UIFont fontWithName:self.unreadCountLabel.font.familyName size:13];
        self.unreadCountLabel.text = number.stringValue;
    }
}

- (void)setIndicatorHidden:(BOOL)hidden animated:(BOOL)animated {
    CGFloat paddingLeft = hidden ? 0 : 13;
    self.indicatorView.alpha = !hidden;
    
    self.groupImageView.x = 18 + paddingLeft;
    self.unreadCountLabel.x = 56 + paddingLeft;
    self.nameLabel.x = 94 + paddingLeft;
    self.championshipLabel.x = self.nameLabel.x;
    self.roundsLabel.x = self.nameLabel.x;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    self.indicatorView.backgroundColor = [[UIColor ftb_greenGrassColor] colorWithAlphaComponent:0.6];
    self.unreadCountLabel.backgroundColor = [UIColor ftb_tabBarTintColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
