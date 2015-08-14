//
//  AskFriendTableViewCell.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/30/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "AskFriendTableViewCell.h"

#pragma mark AskFriendTableViewCell

@implementation AskFriendTableViewCell

#pragma mark - Getters/Setters

- (void)setProfileImageViewHidden:(BOOL)profileImageViewHidden {
    _profileImageViewHidden = profileImageViewHidden;
    
    self.profileImageView.hidden = self.profileImageViewHidden;
    CGRect nameFrame = self.nameLabel.frame;
    if (self.isProfileImageViewHidden) {
        self.nameLabel.frame = CGRectMake(15, 0, CGRectGetWidth(nameFrame), CGRectGetHeight(nameFrame));
    } else {
        self.nameLabel.frame = CGRectMake(57, 0, CGRectGetWidth(nameFrame), CGRectGetHeight(nameFrame));
    }
}

#pragma mark - Instance Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = self.backgroundColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 11, 35, 35)];
        self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.profileImageView.clipsToBounds = YES;
        self.profileImageView.layer.cornerRadius = CGRectGetWidth(self.profileImageView.frame) / 2;
        [self.contentView addSubview:self.profileImageView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(57, 0, CGRectGetWidth(self.frame) - 111, CGRectGetHeight(self.frame))];
        self.nameLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.nameLabel.font = [UIFont fontWithName:kFontNameMedium size:16];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.textColor = [UIColor colorWithRed:93./255.f green:107/255.f blue:97/255.f alpha:1.00];
        [self.contentView addSubview:self.nameLabel];
        
        self.selectionButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 44, 17, 22, 22)];
        self.selectionButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.selectionButton.adjustsImageWhenHighlighted = NO;
        [self.selectionButton setImage:[UIImage imageNamed:@"groups_selectleague_unchecked"] forState:UIControlStateNormal];
        [self.selectionButton setImage:[UIImage imageNamed:@"groups_selectleague_checked"] forState:UIControlStateHighlighted];
        [self.selectionButton setImage:[UIImage imageNamed:@"groups_selectleague_checked"] forState:UIControlStateSelected];
        self.selectionButton.userInteractionEnabled = NO;
        [self.contentView addSubview:self.selectionButton];
        
        [self restoreProfileImagePlaceholder];
    }
    return self;
}

- (void)restoreProfileImagePlaceholder {
    self.profileImageView.image = self.placeholderImage;
}

- (UIImage *)placeholderImage {
    return [UIImage imageNamed:@"avatarless_user"];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    self.selectionButton.highlighted = highlighted;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.selectionButton.selected = selected;
    if (selected) {
        [self.selectionButton setImage:[UIImage imageNamed:@"groups_selectleague_unchecked"] forState:UIControlStateHighlighted];
    } else {
        [self.selectionButton setImage:[UIImage imageNamed:@"groups_selectleague_checked"] forState:UIControlStateHighlighted];
    }
}

@end
