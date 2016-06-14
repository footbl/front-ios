//
//  ProfileChampionshipTableViewCell.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/20/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "ProfileChampionshipTableViewCell.h"
#import "UIView+Frame.h"

#pragma mark ProfileChampionshipTableViewCell

@implementation ProfileChampionshipTableViewCell

#pragma mark - Getters/Setters

- (void)setRankingProgress:(NSNumber *)rankingProgress {
    _rankingProgress = rankingProgress;
    
    CGFloat width = [self.rankingLabel sizeThatFits:self.rankingLabel.bounds.size].width;
    CGFloat rankingCenterX = self.rankingLabel.x + self.rankingLabel.width - (width / 2);
	self.progressLabel.text = self.rankingProgress.stringValue;
	
    if (rankingProgress.integerValue > 0) {
        self.rankingLabel.y = -3;
        self.arrowImageView.image = [UIImage imageNamed:@"up_arrow"];
        self.arrowImageView.center = CGPointMake(rankingCenterX - 8, self.rankingLabel.center.y + 15.5);
    } else if (rankingProgress.integerValue < 0) {
        self.rankingLabel.y = -3;
        self.arrowImageView.image = [UIImage imageNamed:@"down_arrow"];
        self.arrowImageView.center = CGPointMake(rankingCenterX - 8, self.rankingLabel.center.y + 16);
    } else {
        self.rankingLabel.y = 0;
        self.arrowImageView.image = nil;
        self.progressLabel.text = @"";
    }
    
    self.progressLabel.center = CGPointMake(self.rankingLabel.center.x + 7, self.rankingLabel.center.y + 16);
    self.progressLabel.x = self.arrowImageView.center.x + 7;
}

#pragma mark - Instance Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = self.backgroundColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.championshipImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 11, 44, 44)];
        self.championshipImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.championshipImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.championshipImageView];
        
        /*
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 13, 207, 22)];
        */
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 207, 66)];
        self.nameLabel.font = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:16];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.textColor = [UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:1.00];
        [self.contentView addSubview:self.nameLabel];
        
        CGRect frame = self.nameLabel.frame;
        frame.origin.y = CGRectGetMaxY(frame) - 1;
        frame.size.height = 20;
        
        self.informationLabel = [[UILabel alloc] initWithFrame:frame];
        self.informationLabel.font = [UIFont fontWithName:kFontNameMedium size:14];
        self.informationLabel.textAlignment = self.nameLabel.textAlignment;
        self.informationLabel.textColor = [UIColor colorWithRed:141/255.f green:151/255.f blue:144/255.f alpha:1.00];
        [self.contentView addSubview:self.informationLabel];
        
        self.rankingLabel = [[UILabel alloc] initWithFrame:CGRectMake(224, 0, 80, 67)];
        self.rankingLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:14];
        self.rankingLabel.textAlignment = NSTextAlignmentRight;
        self.rankingLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.rankingLabel.textColor = [[UIColor ftb_cellMatchPotColor] colorWithAlphaComponent:0.6];
        [self.contentView addSubview:self.rankingLabel];
        
        self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down_arrow"]];
        [self.contentView addSubview:self.arrowImageView];
        
        self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.rankingLabel.y, 100, self.rankingLabel.height)];
        self.progressLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:10];
        self.progressLabel.textAlignment = NSTextAlignmentLeft;
        self.progressLabel.textColor = [[UIColor ftb_cellMatchPotColor] colorWithAlphaComponent:0.4];
        [self.contentView addSubview:self.progressLabel];
    }
    return self;
}

@end
