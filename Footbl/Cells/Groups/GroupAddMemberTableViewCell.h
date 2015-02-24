//
//  GroupAddMemberTableViewCell.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/5/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TemplateTableViewCell.h"

@interface GroupAddMemberTableViewCell : TemplateTableViewCell

@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIButton *selectionButton;
@property (assign, nonatomic, getter = isProfileImageViewHidden) BOOL profileImageViewHidden;

- (void)restoreProfileImagePlaceholder;
- (UIImage *)placeholderImage;
- (void)restoreFrames;

@end
