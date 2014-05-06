//
//  GroupAddMemberTableViewCell.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/5/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "GroupAddMemberTableViewCell.h"

#pragma mark GroupAddMemberTableViewCell

@implementation GroupAddMemberTableViewCell

#pragma mark - Instance Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
        self.contentView.backgroundColor = self.backgroundColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 11, 44, 44)];
        self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.profileImageView.clipsToBounds = YES;
        self.profileImageView.layer.cornerRadius = CGRectGetWidth(self.profileImageView.frame) / 2;
        [self.contentView addSubview:self.profileImageView];
        
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 14, 185, 22)];
        self.usernameLabel.font = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:16];
        self.usernameLabel.textAlignment = NSTextAlignmentLeft;
        self.usernameLabel.textColor = [[FootblAppearance colorForView:FootblColorCellMatchPot] colorWithAlphaComponent:1.0];
        [self.contentView addSubview:self.usernameLabel];
        
        CGRect nameFrame = self.usernameLabel.frame;
        nameFrame.origin.y += 19;
        self.nameLabel = [[UILabel alloc] initWithFrame:nameFrame];
        self.nameLabel.font = [UIFont fontWithName:kFontNameMedium size:13];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.textColor = [UIColor colorWithRed:141/255.f green:151/255.f blue:144/255.f alpha:1.00];
        [self.contentView addSubview:self.nameLabel];
        
        self.selectionButton = [[UIButton alloc] initWithFrame:CGRectMake(268, 11, 44, 44)];
        [self.selectionButton setImage:[UIImage imageNamed:@"groups_selectleague_unchecked"] forState:UIControlStateNormal];
        [self.selectionButton setImage:[UIImage imageNamed:@"groups_selectleague_checked"] forState:UIControlStateHighlighted];
        [self.selectionButton setImage:[UIImage imageNamed:@"groups_selectleague_checked"] forState:UIControlStateSelected];
        self.selectionButton.userInteractionEnabled = NO;
        [self.contentView addSubview:self.selectionButton];
        
        [self restoreProfileImagePlaceholder];
    }
    return self;
}

- (void)restoreFrames {
    self.usernameLabel.frame = CGRectMake(75, 14, 185, 22);
    CGRect nameFrame = self.usernameLabel.frame;
    nameFrame.origin.y += 19;
    self.nameLabel.frame = nameFrame;
}

- (void)restoreProfileImagePlaceholder {
    self.profileImageView.image = self.placeholderImage;
}

- (UIImage *)placeholderImage {
    return [UIImage imageNamed:@"avatarless_user"];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];

    if (!self.isSelected || !highlighted) {
        self.selectionButton.highlighted = highlighted;
    }
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
