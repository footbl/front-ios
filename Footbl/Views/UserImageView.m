//
//  UserImageView.m
//  Footbl
//
//  Created by Leonardo Formaggio on 6/14/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>

#import "UserImageView.h"

@implementation UserImageView

- (void)commomInit {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = CGRectGetHeight(self.frame) / 2;
    self.clipsToBounds = YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commomInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    [self commomInit];
}

- (void)setRingVisible:(BOOL)ringVisible {
    _ringVisible = ringVisible;

    self.layer.borderWidth = ringVisible ? 2 : 0;
}

- (void)setUser:(FTBUser *)user {
    _user = user;

    self.layer.borderColor = user.isMe ? [UIColor ftb_blueReturnColor].CGColor : [UIColor ftb_redStakeColor].CGColor;
    [self sd_setImageWithURL:user.pictureURL placeholderImage:[UIImage imageNamed:@"FriendsGenericProfilePic"]];
    self.hidden = !user;
    self.ringVisible = user.isMe;
}

@end
