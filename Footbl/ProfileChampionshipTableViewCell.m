//
//  ProfileChampionshipTableViewCell.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/20/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "ProfileChampionshipTableViewCell.h"

#pragma mark ProfileChampionshipTableViewCell

@implementation ProfileChampionshipTableViewCell

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
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 13, 207, 22)];
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
        self.rankingLabel.textColor = [[FootblAppearance colorForView:FootblColorCellMatchPot] colorWithAlphaComponent:0.6];
        [self.contentView addSubview:self.rankingLabel];
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 66.5, CGRectGetWidth(self.contentView.frame), 0.5)];
        separatorView.backgroundColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.83 alpha:1];
        separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:separatorView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
