//
//  ChatTableViewCell.h
//  Footbl
//
//  Created by Fernando Saragoca on 11/23/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TemplateTableViewCell.h"

@interface ChatTableViewCell : TemplateTableViewCell

@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UILabel *profileNameLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *messageLabel;

- (void)setProfileName:(NSString *)name message:(NSString *)message pictureURL:(NSURL *)pictureURL date:(NSDate *)date shouldUseRightAlignment:(BOOL)shouldUseRightAlignment;

@end
