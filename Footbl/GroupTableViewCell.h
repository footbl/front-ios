//
//  GroupTableViewCell.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TemplateTableViewCell.h"

@interface GroupTableViewCell : TemplateTableViewCell

@property (strong, nonatomic) UIImageView *groupImageView;
@property (strong, nonatomic) UIView *indicatorView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *championshipLabel;
@property (strong, nonatomic) UILabel *roundsLabel;
@property (strong, nonatomic) UILabel *unreadCountLabel;
@property (strong, nonatomic) UIView *topSeparatorView;
@property (strong, nonatomic) UIView *bottomSeparatorView;

- (void)setIndicatorHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setUnreadCount:(NSNumber *)number;

@end
