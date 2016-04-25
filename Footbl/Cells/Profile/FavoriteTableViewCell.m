//
//  FavoriteTableViewCell.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/23/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "FavoriteTableViewCell.h"
#import "UIView+Frame.h"

@interface FavoriteTableViewCell ()

@property (strong, nonatomic) UIImageView *verifiedImageView;

@end

#pragma mark FavoriteTableViewCell

@implementation FavoriteTableViewCell

#pragma mark - Getters/Setters

- (void)setVerified:(BOOL)verified {
    _verified = verified;
    
    self.verifiedImageView.hidden = !self.isVerified;
    
    CGFloat width = [self.usernameLabel sizeThatFits:self.usernameLabel.bounds.size].width;
    self.verifiedImageView.x = self.usernameLabel.x + width + 10;
    self.verifiedImageView.center = CGPointMake(self.verifiedImageView.center.x, self.usernameLabel.center.y);
}

#pragma mark - Instance Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.backgroundColor = [UIColor ftb_viewMatchBackgroundColor];
        self.contentView.backgroundColor = self.backgroundColor;
        
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 11, 44, 44)];
        self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.profileImageView.clipsToBounds = YES;
        self.profileImageView.layer.cornerRadius = CGRectGetWidth(self.profileImageView.frame) / 2;
        self.profileImageView.image = self.placeholderImage;
        [self.contentView addSubview:self.profileImageView];
        
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 13, 185, 22)];
        self.usernameLabel.font = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:16];
        self.usernameLabel.textAlignment = NSTextAlignmentLeft;
        self.usernameLabel.textColor = [[UIColor ftb_cellMatchPotColor] colorWithAlphaComponent:1.0];
        [self.contentView addSubview:self.usernameLabel];
        
        CGRect nameFrame = self.usernameLabel.frame;
        nameFrame.origin.y += 17;
        self.nameLabel = [[UILabel alloc] initWithFrame:nameFrame];
        self.nameLabel.font = [UIFont fontWithName:kFontNameMedium size:13];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.textColor = [UIColor colorWithRed:141/255.f green:151/255.f blue:144/255.f alpha:1.00];
        [self.contentView addSubview:self.nameLabel];
        
        self.verifiedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verified_badge"]];
        self.verifiedImageView.hidden = YES;
        self.verifiedImageView.frame = CGRectMake(185, 16, 16, 16);
        [self.contentView addSubview:self.verifiedImageView];
        
        /*
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 65.5, CGRectGetWidth(self.contentView.frame), 0.5)];
        separatorView.backgroundColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.83 alpha:1];
        separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:separatorView];
        */
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
