//
//  ProfileChampionshipTableViewCell.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/20/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateTableViewCell.h"

@interface ProfileChampionshipTableViewCell : TemplateTableViewCell

@property (strong, nonatomic) UIImageView *championshipImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *informationLabel;
@property (strong, nonatomic) UILabel *rankingLabel;
@property (strong, nonatomic) UIImageView *arrowImageView;
@property (strong, nonatomic) UILabel *progressLabel;
@property (strong, nonatomic) NSNumber *rankingProgress;

@end
