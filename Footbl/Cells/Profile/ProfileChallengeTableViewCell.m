//
//  ProfileChallengeTableViewCell.m
//  Footbl
//
//  Created by Leonardo Formaggio on 4/3/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import "ProfileChallengeTableViewCell.h"

@implementation ProfileChallengeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor ftb_greenGrassColor];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.titleLabel.font = [UIFont fontWithName:kFontNameAvenirNextRegular size:30];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = @"Challenge!";
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

@end
