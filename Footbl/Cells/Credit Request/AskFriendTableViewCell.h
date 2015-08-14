//
//  AskFriendTableViewCell.h
//  Footbl
//
//  Created by Fernando Saragoça on 7/30/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateTableViewCell.h"

@interface AskFriendTableViewCell : TemplateTableViewCell

@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIButton *selectionButton;
@property (assign, nonatomic, getter = isProfileImageViewHidden) BOOL profileImageViewHidden;

- (void)restoreProfileImagePlaceholder;
- (UIImage *)placeholderImage;

@end
