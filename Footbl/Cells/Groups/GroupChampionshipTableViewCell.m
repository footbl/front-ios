//
//  GroupChampionshipTableViewCell.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/3/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "GroupChampionshipTableViewCell.h"

#pragma mark GroupChampionshipTableViewCell

@implementation GroupChampionshipTableViewCell

#pragma mark - Instance Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
        self.contentView.backgroundColor = self.backgroundColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.championshipImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 8, 44, 44)];
        self.championshipImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.championshipImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.championshipImageView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 11, 185, 22)];
        self.nameLabel.font = [UIFont fontWithName:kFontNameMedium size:16];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.textColor = [[FootblAppearance colorForView:FootblColorCellMatchPot] colorWithAlphaComponent:1.0];
        [self.contentView addSubview:self.nameLabel];
        
        CGRect nameFrame = self.nameLabel.frame;
        nameFrame.origin.y += 19;
        self.informationLabel = [[UILabel alloc] initWithFrame:nameFrame];
        self.informationLabel.font = [UIFont fontWithName:kFontNameMedium size:13];
        self.informationLabel.textAlignment = NSTextAlignmentLeft;
        self.informationLabel.textColor = [UIColor colorWithRed:141/255.f green:151/255.f blue:144/255.f alpha:1.00];
        [self.contentView addSubview:self.informationLabel];
        
        self.selectionButton = [[UIButton alloc] initWithFrame:CGRectMake(268, 8, 44, 44)];
        [self.selectionButton setImage:[UIImage imageNamed:@"groups_selectleague_unchecked"] forState:UIControlStateNormal];
        [self.selectionButton setImage:[UIImage imageNamed:@"groups_selectleague_checked"] forState:UIControlStateHighlighted];
        [self.selectionButton setImage:[UIImage imageNamed:@"groups_selectleague_checked"] forState:UIControlStateSelected];
        self.selectionButton.userInteractionEnabled = NO;
        self.selectionButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addSubview:self.selectionButton];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    self.selectionButton.highlighted = highlighted;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.selectionButton.selected = selected;
}

@end
