//
//  WalletTableViewCell.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/20/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "WalletTableViewCell.h"

@interface WalletTableViewCell ()

@property (strong, nonatomic) UILabel *valueLabel;
@property (strong, nonatomic) UIImageView *signImageView;

@end

#pragma mark WalletTableViewCell

@implementation WalletTableViewCell

#pragma mark - Getters/Setters

- (void)setValueText:(NSString *)valueText {
    _valueText = valueText;
    
    self.valueLabel.text = self.valueText;
    
    CGPoint labelCenter = CGPointMake(CGRectGetMidX(self.contentView.frame), CGRectGetMidY(self.valueLabel.frame));
    labelCenter.x += (CGRectGetWidth(self.signImageView.frame) + 10) / 2;
    [self.valueLabel sizeToFit];
    self.valueLabel.center = labelCenter;
    
    self.signImageView.center = CGPointMake(CGRectGetMinX(self.valueLabel.frame) - (CGRectGetWidth(self.signImageView.frame) + 10) / 2, labelCenter.y - 1);
}

#pragma mark - Instance Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, CGRectGetWidth(self.contentView.frame), 37)];
        self.valueLabel.font = [UIFont fontWithName:kFontNameAvenirNextRegular size:30];
        self.valueLabel.textColor = [UIColor ftb_greenMoneyColor];
        self.valueLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.valueLabel];
        
        self.signImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"money_sign"]];
        [self.contentView addSubview:self.signImageView];
    }
    return self;
}

@end
