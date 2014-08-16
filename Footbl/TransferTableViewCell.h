//
//  TransferTableViewCell.h
//  Footbl
//
//  Created by Fernando Saragoça on 8/15/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TemplateTableViewCell.h"

@interface TransferTableViewCell : TemplateTableViewCell

@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *valueLabel;

- (void)restoreProfileImagePlaceholder;
- (void)setEnabled:(BOOL)enabled;
- (UIImage *)placeholderImage;

@end
