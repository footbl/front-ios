//
//  ProfileTableViewCell.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/20/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "ProfileTableViewCell.h"

@interface ProfileTableViewCell ()

@property (strong, nonatomic) UIImageView *verifiedImageView;

@end

#pragma mark ProfileTableViewCell

@implementation ProfileTableViewCell

#pragma mark - Getters/Setters

- (void)setVerified:(BOOL)verified {
    _verified = verified;
    
    self.verifiedImageView.hidden = !self.isVerified;
    if (self.isVerified) {
        CGRect frame = self.verifiedImageView.frame;
        frame.origin.y = CGRectGetMidY(self.usernameLabel.frame) - CGRectGetHeight(frame) / 2;
        frame.origin.x = CGRectGetMinX(self.usernameLabel.frame) + [self.usernameLabel sizeThatFits:CGSizeMake(INT_MAX, CGRectGetHeight(self.usernameLabel.frame))].width + 5;
        self.verifiedImageView.frame = frame;
    }
}

#pragma mark - Instance Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
        self.contentView.backgroundColor = self.backgroundColor;
        
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 25, 44, 44)];
        self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.profileImageView.clipsToBounds = YES;
        self.profileImageView.layer.cornerRadius = CGRectGetWidth(self.profileImageView.frame) / 2;
        self.profileImageView.image = self.placeholderImage;
        [self.contentView addSubview:self.profileImageView];
        
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 20, 185, 22)];
        self.usernameLabel.font = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:16];
        self.usernameLabel.textAlignment = NSTextAlignmentLeft;
        self.usernameLabel.textColor = [[FootblAppearance colorForView:FootblColorCellMatchPot] colorWithAlphaComponent:1.0];
        [self.contentView addSubview:self.usernameLabel];
        
        CGRect nameFrame = self.usernameLabel.frame;
        nameFrame.origin.y += 17;
        self.nameLabel = [[UILabel alloc] initWithFrame:nameFrame];
        self.nameLabel.font = [UIFont fontWithName:kFontNameMedium size:13];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.textColor = [UIColor colorWithRed:141/255.f green:151/255.f blue:144/255.f alpha:1.00];
        [self.contentView addSubview:self.nameLabel];
        
        CGRect dateFrame = self.nameLabel.frame;
        dateFrame.origin.y += 17;
        self.dateLabel = [[UILabel alloc] initWithFrame:dateFrame];
        self.dateLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:10];
        self.dateLabel.textAlignment = NSTextAlignmentLeft;
        self.dateLabel.textColor = [[FootblAppearance colorForView:FootblColorCellMatchPot] colorWithAlphaComponent:0.6];
        [self.contentView addSubview:self.dateLabel];
        
        self.verifiedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verified_badge"]];
        self.verifiedImageView.hidden = YES;
        [self.contentView addSubview:self.verifiedImageView];
        
        self.starImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star_inactive"] highlightedImage:[UIImage imageNamed:@"star_active"]];
        self.starImageView.center = CGPointMake(CGRectGetWidth(self.contentView.frame) - 40, CGRectGetMidY(self.nameLabel.frame));
        [self.contentView addSubview:self.starImageView];
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 92.5, CGRectGetWidth(self.contentView.frame), 0.5)];
        separatorView.backgroundColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.83 alpha:1];
        separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:separatorView];
    }
    return self;
}

- (UIImage *)placeholderImage {
    return [UIImage imageNamed:@"avatarless_user"];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    self.starImageView.highlighted = highlighted || self.isSelected;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.starImageView.highlighted = selected;
}

@end
