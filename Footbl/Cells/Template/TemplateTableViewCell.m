//
//  TemplateTableViewCell.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateTableViewCell.h"

#pragma mark TemplateTableViewCell

@implementation TemplateTableViewCell

#pragma mark - Instance Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor ftb_cellBackgroundColor];
        self.backgroundColor = [UIColor ftb_cellBackgroundColor];
    }
    return self;
}

- (UIEdgeInsets)layoutMargins {
    return UIEdgeInsetsZero;
}

@end
