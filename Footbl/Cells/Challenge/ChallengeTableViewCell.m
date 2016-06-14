//
//  ChallengeTableViewCell.m
//  Footbl
//
//  Created by Leonardo Formaggio on 9/30/15.
//  Copyright © 2015 Footbl. All rights reserved.
//

#import "ChallengeTableViewCell.h"

@implementation ChallengeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.userImageView.clipsToBounds = YES;
    self.userImageView.layer.cornerRadius = CGRectGetWidth(self.userImageView.frame) / 2;
    self.userImageView.layer.borderColor = [UIColor ftb_redStakeColor].CGColor;
}

- (void)setRingVisible:(BOOL)ringVisible {
    _ringVisible = ringVisible;

    self.userImageView.layer.borderWidth = ringVisible ? 2 : 0;
}

@end
