//
//  ChatTableViewCell.m
//  Footbl
//
//  Created by Fernando Saragoca on 11/23/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <SPHipster/UIView+Frame.h>
#import "ChatTableViewCell.h"
#import "NSDate+Utils.h"

#pragma mark ChatTableViewCell

@implementation ChatTableViewCell

#pragma mark - Instance Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = self.backgroundColor;
        
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.separatorInset.left, 5, 24, 24)];
        self.profileImageView.backgroundColor = [UIColor whiteColor];
        self.profileImageView.layer.cornerRadius = CGRectGetHeight(self.profileImageView.frame) / 2;
        self.profileImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.profileImageView];
        
        self.profileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.profileImageView.frameX + self.profileImageView.frameWidth + self.profileImageView.frameX - 4, 0, 220, 34)];
        self.profileNameLabel.font = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:14];
        self.profileNameLabel.textAlignment = NSTextAlignmentLeft;
        self.profileNameLabel.textColor = [UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:1.00];
        [self.contentView addSubview:self.profileNameLabel];
        
        self.dateLabel = [[UILabel alloc] initWithFrame:self.profileNameLabel.frame];
        self.dateLabel.font = [UIFont fontWithName:kFontNameAvenirNextRegular size:14];
        self.dateLabel.textAlignment = NSTextAlignmentLeft;
        self.dateLabel.textColor = [UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:0.7];
        [self.contentView addSubview:self.dateLabel];
        
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frameWidth, 30)];
        self.messageLabel.font = [UIFont fontWithName:kFontNameAvenirNextRegular size:14];
        self.messageLabel.textAlignment = NSTextAlignmentLeft;
        self.messageLabel.textColor = [UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:1.00];
        self.messageLabel.numberOfLines = 0;
        [self.contentView addSubview:self.messageLabel];
    }
    return self;
}

- (void)setProfileName:(NSString *)name message:(NSString *)message pictureURL:(NSURL *)pictureURL date:(NSDate *)date shouldUseRightAlignment:(BOOL)shouldUseRightAlignment {
    self.messageLabel.textColor = [UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:1.00];
    self.messageLabel.text = message;
    
    self.profileImageView.frameX = self.separatorInset.left;
    self.profileNameLabel.frameX = self.profileImageView.frameX + self.profileImageView.frameWidth + self.profileImageView.frameX - 4;
    
    CGFloat messageWidth = self.contentView.frameWidth * 0.66;
    CGFloat messageHeight = [self.messageLabel sizeThatFits:CGSizeMake(messageWidth, INT_MAX)].height;
    self.messageLabel.frame = CGRectMake(self.profileImageView.frameX - 1 + self.profileImageView.frameWidth / 2, self.messageLabel.frameY, messageWidth, messageHeight);
    self.messageLabel.textAlignment = NSTextAlignmentLeft;
    
    if (name) {
        self.profileImageView.hidden = NO;
        self.profileNameLabel.hidden = NO;
        self.dateLabel.hidden = NO;
        
        [self.profileImageView sd_setImageWithURL:pictureURL placeholderImage:[UIImage imageNamed:@"avatarless_user"]];
        self.profileNameLabel.text = name;
        
        CGFloat nameWidth = [self.profileNameLabel sizeThatFits:CGSizeMake(self.contentView.frameWidth, self.profileNameLabel.frameHeight)].width;
        self.profileNameLabel.frameWidth = nameWidth;
        CGFloat dateOriginX = self.profileNameLabel.frameX + nameWidth;
        self.dateLabel.frame = CGRectMake(dateOriginX, self.profileNameLabel.frameY, self.contentView.frameWidth - dateOriginX, self.profileNameLabel.frameHeight);
        
        if (date) {
            NSDateFormatter *formatter = [NSDateFormatter new];
            if (date.isToday) {
                formatter.dateStyle = NSDateFormatterNoStyle;
            } else {
                formatter.dateStyle = NSDateFormatterShortStyle;
            }
            formatter.timeStyle = NSDateFormatterShortStyle;
            if (shouldUseRightAlignment) {
                self.dateLabel.text = [[formatter stringFromDate:date] stringByAppendingString:@" @ "];
            } else {
                self.dateLabel.text = [@" @ " stringByAppendingString:[formatter stringFromDate:date]];
            }
        } else {
            self.dateLabel.text = @"";
        }
        
        self.messageLabel.frameY = self.profileImageView.frameHeight + self.profileImageView.frameY + self.profileImageView.frameY;
    } else {
        self.profileImageView.hidden = YES;
        self.profileNameLabel.hidden = YES;
        self.dateLabel.hidden = YES;
        self.messageLabel.frameY = 0;
    }
    
    if (shouldUseRightAlignment) {
        self.profileImageView.frameX = self.contentView.frameWidth - self.profileImageView.frameX - self.profileImageView.frameWidth;
        self.profileNameLabel.frameX = self.contentView.frameWidth - self.profileNameLabel.frameX - self.profileNameLabel.frameWidth;
        self.dateLabel.frameWidth = [self.dateLabel sizeThatFits:CGSizeMake(self.contentView.frameWidth - self.profileNameLabel.frameX, self.dateLabel.frameHeight)].width;
        self.dateLabel.frameX = self.profileNameLabel.frameX - self.dateLabel.frameWidth;
        self.messageLabel.frameX = self.contentView.frameWidth - self.messageLabel.frameWidth - self.messageLabel.frameX + 1;
        self.messageLabel.textAlignment = NSTextAlignmentRight;
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, self.messageLabel.frameY + self.messageLabel.frameHeight + self.profileImageView.frameY);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
