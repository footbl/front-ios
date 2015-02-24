//
//  GroupMembershipTableViewCell.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/10/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TemplateTableViewCell.h"

@interface GroupMembershipTableViewCell : TemplateTableViewCell

@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UIImageView *arrowImageView;
@property (strong, nonatomic) UILabel *progressLabel;
@property (strong, nonatomic) UILabel *rankingLabel;
@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *walletLabel;
@property (strong, nonatomic) NSNumber *rankingProgress;
@property (strong, nonatomic) UIImageView *medalImageView;

- (UIImage *)placeholderImage;

@end
