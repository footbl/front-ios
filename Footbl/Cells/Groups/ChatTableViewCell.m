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

CGFloat const MARGIN	= 10.0f;

#pragma mark ChatTableViewCell

@implementation ChatTableViewCell

#pragma mark - Instance Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = self.backgroundColor;
        
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(MARGIN, 5, 24, 24)];
        self.profileImageView.backgroundColor = [UIColor whiteColor];
        self.profileImageView.layer.cornerRadius = CGRectGetHeight(self.profileImageView.frame) / 2;
        self.profileImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.profileImageView];
        
        self.profileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.profileImageView.width + 2 * MARGIN, 0, 220, 34)];
        self.profileNameLabel.font = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:14];
        self.profileNameLabel.textAlignment = NSTextAlignmentLeft;
        self.profileNameLabel.textColor = [UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:1.00];
        [self.contentView addSubview:self.profileNameLabel];
        
        self.dateLabel = [[UILabel alloc] initWithFrame:self.profileNameLabel.frame];
        self.dateLabel.font = [UIFont fontWithName:kFontNameAvenirNextRegular size:14];
        self.dateLabel.textAlignment = NSTextAlignmentLeft;
        self.dateLabel.textColor = [UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:0.7];
        [self.contentView addSubview:self.dateLabel];
        
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 30)];
        self.messageLabel.font = [UIFont fontWithName:kFontNameAvenirNextRegular size:14];
        self.messageLabel.textAlignment = NSTextAlignmentLeft;
        self.messageLabel.textColor = [UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:1.00];
        self.messageLabel.numberOfLines = 0;
        [self.contentView addSubview:self.messageLabel];
		
		self.messageImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		self.messageImageView.contentMode = UIViewContentModeScaleAspectFill;
		self.messageImageView.autoresizingMask = UIViewAutoresizingNone;
		[self.contentView addSubview:self.messageImageView];
    }
    return self;
}

- (void)setProfileName:(NSString *)name message:(NSString *)message imageURL:(NSURL *)imageURL placeholder:(UIImage *)placeholder pictureURL:(NSURL *)pictureURL date:(NSDate *)date shouldUseRightAlignment:(BOOL)shouldUseRightAlignment {
	self.profileImageView.x = MARGIN;
    self.profileNameLabel.x = self.profileImageView.x + self.profileImageView.width + self.profileImageView.x - 4;
	
	if (message) {
		self.messageLabel.hidden = NO;
		self.messageLabel.textColor = [UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:1.00];
		self.messageLabel.text = message;
		CGFloat messageWidth = self.contentView.width * 0.66;
		CGFloat messageHeight = [self.messageLabel sizeThatFits:CGSizeMake(messageWidth, INT_MAX)].height;
		self.messageLabel.frame = CGRectMake(self.profileImageView.x + self.profileImageView.width / 2, self.messageLabel.y, messageWidth, messageHeight);
		self.messageLabel.textAlignment = NSTextAlignmentLeft;
	}
	
	if (imageURL) {
		self.messageImageView.hidden = NO;
		self.messageImageView.frame = CGRectMake(self.profileImageView.x + self.profileImageView.width / 2, 0, 160, 160);
		[self.messageImageView sd_setImageWithURL:imageURL placeholderImage:placeholder];
	}
	
    if (name) {
        self.profileImageView.hidden = NO;
        self.profileNameLabel.hidden = NO;
        self.dateLabel.hidden = NO;
        
        [self.profileImageView sd_setImageWithURL:pictureURL placeholderImage:[UIImage imageNamed:@"avatarless_user"]];
        self.profileNameLabel.text = name;
        
        CGFloat nameWidth = [self.profileNameLabel sizeThatFits:CGSizeMake(self.contentView.width, self.profileNameLabel.height)].width;
        self.profileNameLabel.width = nameWidth;
        CGFloat dateOriginX = self.profileNameLabel.x + nameWidth;
        self.dateLabel.frame = CGRectMake(dateOriginX, self.profileNameLabel.y, self.contentView.width - dateOriginX, self.profileNameLabel.height);
        
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
        
        self.messageLabel.y = self.profileImageView.height + 2 * self.profileImageView.y;
		self.messageImageView.y = self.profileImageView.height + 2 * self.profileImageView.y + MARGIN;
    } else {
        self.profileImageView.hidden = YES;
        self.profileNameLabel.hidden = YES;
        self.dateLabel.hidden = YES;
        self.messageLabel.y = 0;
		self.messageImageView.y = MARGIN / 2;
    }
    
    if (shouldUseRightAlignment) {
        self.profileImageView.maxX = self.contentView.width - MARGIN;
		self.profileNameLabel.maxX = self.profileImageView.x - MARGIN / 2;
        self.dateLabel.width = [self.dateLabel sizeThatFits:CGSizeMake(self.contentView.width - self.profileNameLabel.x, self.dateLabel.height)].width;
        self.dateLabel.x = self.profileNameLabel.x - self.dateLabel.width;
        self.messageLabel.x = self.contentView.width - self.messageLabel.width - MARGIN;
		self.messageImageView.x = self.contentView.width - self.messageImageView.width - MARGIN;
        self.messageLabel.textAlignment = NSTextAlignmentRight;
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
	CGFloat textHeight = self.messageLabel.y + self.messageLabel.height + self.profileImageView.y;
	CGFloat imageHeight = self.messageImageView.y + self.messageImageView.height + self.profileImageView.y;
	CGFloat height = MAX(textHeight, imageHeight);
    return CGSizeMake(size.width, height);
}

- (void)prepareForReuse {
	[super prepareForReuse];
	
	self.messageImageView.frame = CGRectZero;
	self.messageImageView.image = nil;
	self.messageImageView.hidden = YES;
	
	self.messageLabel.text = nil;
	self.messageLabel.hidden = YES;
}

@end
