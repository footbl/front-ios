//
//  GroupMembershipTableViewCell.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/10/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "GroupMembershipTableViewCell.h"
#import "UIView+Frame.h"

#pragma mark GroupMembershipTableViewCell

@implementation GroupMembershipTableViewCell

#pragma mark - Getters/Setters

- (void)setRankingProgress:(NSNumber *)rankingProgress {
    _rankingProgress = rankingProgress;
    
    CGFloat width = [self.rankingLabel sizeThatFits:self.rankingLabel.bounds.size].width;
    self.arrowImageView.x = self.rankingLabel.x + width + 3;
	self.progressLabel.text = self.rankingProgress.stringValue;
    self.progressLabel.x = self.arrowImageView.x + self.arrowImageView.width + 4;
    
    if (rankingProgress.integerValue > 0) {
        self.arrowImageView.image = [UIImage imageNamed:@"up_arrow"];
        self.arrowImageView.center = CGPointMake(self.arrowImageView.center.x, self.rankingLabel.center.y - 0.5);
    } else if (rankingProgress.integerValue < 0) {
        self.arrowImageView.image = [UIImage imageNamed:@"down_arrow"];
        self.arrowImageView.center = CGPointMake(self.arrowImageView.center.x, self.rankingLabel.center.y);
    } else {
        self.arrowImageView.image = nil;
        self.progressLabel.text = @"";
    }
}

#pragma mark - Instance Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor ftb_viewMatchBackgroundColor];
        self.contentView.backgroundColor = self.backgroundColor;
        
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 44, 44)];
        self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.profileImageView.clipsToBounds = YES;
        self.profileImageView.layer.cornerRadius = CGRectGetWidth(self.profileImageView.frame) / 2;
        self.profileImageView.image = self.placeholderImage;
        [self.contentView addSubview:self.profileImageView];
        
        self.medalImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 35, 28, 28)];
        [self.contentView addSubview:self.medalImageView];
        
        self.rankingLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 11, 185, 16)];
        self.rankingLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:10];
        self.rankingLabel.textAlignment = NSTextAlignmentLeft;
        self.rankingLabel.textColor = [[UIColor ftb_cellMatchPotColor] colorWithAlphaComponent:0.6];
        [self.contentView addSubview:self.rankingLabel];
        
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 26, 175, 22)];
        self.usernameLabel.font = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:16];
        self.usernameLabel.textAlignment = NSTextAlignmentLeft;
        self.usernameLabel.textColor = [[UIColor ftb_cellMatchPotColor] colorWithAlphaComponent:1.0];
        [self.contentView addSubview:self.usernameLabel];
        
        CGRect nameFrame = self.usernameLabel.frame;
        nameFrame.origin.y += 19;
        self.nameLabel = [[UILabel alloc] initWithFrame:nameFrame];
        self.nameLabel.font = [UIFont fontWithName:kFontNameMedium size:13];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.textColor = [UIColor colorWithRed:141/255.f green:151/255.f blue:144/255.f alpha:1.00];
        [self.contentView addSubview:self.nameLabel];
        
        self.walletLabel = [[UILabel alloc] initWithFrame:CGRectMake(244, 0, 60, 71)];
        self.walletLabel.font = [UIFont fontWithName:kFontNameAvenirNextRegular size:20];
        self.walletLabel.textAlignment = NSTextAlignmentRight;
        self.walletLabel.textColor = [[UIColor ftb_cellMatchPotColor] colorWithAlphaComponent:1.0];
        self.walletLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addSubview:self.walletLabel];
        
        self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down_arrow"]];
        self.arrowImageView.center = CGPointMake(100, self.rankingLabel.center.y);
        [self.contentView addSubview:self.arrowImageView];
        
        self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.rankingLabel.y, 100, self.rankingLabel.height)];
        self.progressLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:10];
        self.progressLabel.textAlignment = NSTextAlignmentLeft;
        self.progressLabel.textColor = [[UIColor ftb_cellMatchPotColor] colorWithAlphaComponent:0.4];
        [self.contentView addSubview:self.progressLabel];
    }
    return self;
}

- (UIImage *)placeholderImage {
    return [UIImage imageNamed:@"FriendsGenericProfilePic"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
