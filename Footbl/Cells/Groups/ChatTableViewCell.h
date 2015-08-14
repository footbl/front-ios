//
//  ChatTableViewCell.h
//  Footbl
//
//  Created by Fernando Saragoca on 11/23/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateTableViewCell.h"

@interface ChatTableViewCell : TemplateTableViewCell

@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UILabel *profileNameLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIImageView *messageImageView;

- (void)setProfileName:(NSString *)name
			   message:(NSString *)message
			  imageURL:(NSURL *)imageURL
		   placeholder:(UIImage *)placeholder
			pictureURL:(NSURL *)pictureURL
				  date:(NSDate *)date
shouldUseRightAlignment:(BOOL)shouldUseRightAlignment;

@end
