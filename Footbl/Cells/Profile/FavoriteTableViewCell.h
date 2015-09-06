//
//  FavoriteTableViewCell.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/23/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateTableViewCell.h"

@interface FavoriteTableViewCell : TemplateTableViewCell

@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (assign, nonatomic, getter = isVerified) BOOL verified;

- (UIImage *)placeholderImage;

@end
