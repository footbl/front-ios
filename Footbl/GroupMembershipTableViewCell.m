//
//  GroupMembershipTableViewCell.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/10/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "GroupMembershipTableViewCell.h"

#pragma mark GroupMembershipTableViewCell

@implementation GroupMembershipTableViewCell

#pragma mark - Instance Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
        self.contentView.backgroundColor = self.backgroundColor;
        
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 44, 44)];
        self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.profileImageView.clipsToBounds = YES;
        self.profileImageView.layer.cornerRadius = CGRectGetWidth(self.profileImageView.frame) / 2;
        self.profileImageView.image = self.placeholderImage;
        [self.contentView addSubview:self.profileImageView];
        
        self.rankingLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 11, 185, 16)];
        self.rankingLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:10];
        self.rankingLabel.textAlignment = NSTextAlignmentLeft;
        self.rankingLabel.textColor = [[FootblAppearance colorForView:FootblColorCellMatchPot] colorWithAlphaComponent:0.6];
        [self.contentView addSubview:self.rankingLabel];
        
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 26, 185, 22)];
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
        
        self.walletLabel = [[UILabel alloc] initWithFrame:CGRectMake(264, 0, 40, 71)];
        self.walletLabel.font = [UIFont fontWithName:kFontNameAvenirNextRegular size:20];
        self.walletLabel.textAlignment = NSTextAlignmentLeft;
        self.walletLabel.textColor = [[FootblAppearance colorForView:FootblColorCellMatchPot] colorWithAlphaComponent:1.0];
        [self.contentView addSubview:self.walletLabel];
    }
    return self;
}

- (UIImage *)placeholderImage {
    return [UIImage imageNamed:@"avatarless_user"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
