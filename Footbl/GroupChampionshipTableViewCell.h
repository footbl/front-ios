//
//  GroupChampionshipTableViewCell.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/3/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TemplateTableViewCell.h"

@interface GroupChampionshipTableViewCell : TemplateTableViewCell

@property (strong, nonatomic) UIImageView *championshipImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *informationLabel;
@property (strong, nonatomic) UIButton *selectionButton;

@end
