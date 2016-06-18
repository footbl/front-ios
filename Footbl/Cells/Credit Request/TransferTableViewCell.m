//
//  TransferTableViewCell.m
//  Footbl
//
//  Created by Fernando Saragoça on 8/15/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TransferTableViewCell.h"

#pragma mark TransferTableViewCell

@implementation TransferTableViewCell

#pragma mark - Instance Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor ftb_viewMatchBackgroundColor];
        self.contentView.backgroundColor = self.backgroundColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.tintColor = [UIColor ftb_greenMoneyColor];
        
        self.profileImageView = [[UIImageView alloc] init];
        self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.profileImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.profileImageView];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.nameLabel.font = [UIFont fontWithName:kFontNameMedium size:16];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.textColor = [UIColor colorWithRed:93./255.f green:107/255.f blue:97/255.f alpha:1.00];
        [self.contentView addSubview:self.nameLabel];
        
        self.valueLabel = [[UILabel alloc] init];
        self.valueLabel.font = [UIFont fontWithName:kFontNameAvenirNextRegular size:24];
        self.valueLabel.textAlignment = NSTextAlignmentRight;
        self.valueLabel.textColor = [[UIColor ftb_cellMatchPotColor] colorWithAlphaComponent:1.0];
        [self.contentView addSubview:self.valueLabel];
        
        [self restoreProfileImagePlaceholder];
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    if (enabled) {
        self.nameLabel.textColor = [UIColor colorWithRed:93./255.f green:107/255.f blue:97/255.f alpha:1.00];
    } else {
        self.nameLabel.textColor = [UIColor colorWithRed:0.71 green:0.74 blue:0.72 alpha:1];
    }
}

- (void)restoreProfileImagePlaceholder {
    self.profileImageView.image = self.placeholderImage;
}

- (UIImage *)placeholderImage {
    return [UIImage imageNamed:@"FriendsGenericProfilePic"];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.valueLabel.textColor = [UIColor colorWithRed:0.21 green:0.78 blue:0.46 alpha:1];
        self.valueLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:24];
    } else {
        self.valueLabel.textColor = [[UIColor ftb_cellMatchPotColor] colorWithAlphaComponent:1.0];
        self.valueLabel.font = [UIFont fontWithName:kFontNameAvenirNextRegular size:24];
    }
}

- (void)drawRect:(CGRect)rect {
    self.profileImageView.frame = CGRectMake(11, 11, 35, 35);
    self.nameLabel.frame = CGRectMake(57, 0, CGRectGetWidth(self.frame) - 111, CGRectGetHeight(self.frame));
    self.valueLabel.frame = CGRectMake(CGRectGetWidth(self.frame) - 76, 0, 60, 58);
    self.profileImageView.layer.cornerRadius = CGRectGetWidth(self.profileImageView.frame) / 2;
}

@end
