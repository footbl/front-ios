//
//  SettingsTableViewCell.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/25/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "SettingsTableViewCell.h"

#pragma mark SettingsTableViewCell

@implementation SettingsTableViewCell

#pragma mark - Instance Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = self.backgroundColor;
        
        self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(self.contentView.frame) - 30, CGRectGetHeight(self.contentView.frame))];
        self.infoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.infoLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
