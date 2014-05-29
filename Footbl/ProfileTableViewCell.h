//
//  ProfileTableViewCell.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/20/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TemplateTableViewCell.h"

@interface ProfileTableViewCell : TemplateTableViewCell

@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UIImageView *starImageView;
@property (strong, nonatomic) UILabel *followersLabel;
@property (assign, nonatomic, getter = isVerified) BOOL verified;
@property (copy, nonatomic) NSString *aboutText;

- (UIImage *)placeholderImage;

@end
