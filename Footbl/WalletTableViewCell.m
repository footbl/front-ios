//
//  WalletTableViewCell.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/20/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
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
        // Initialization code
        self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, CGRectGetWidth(self.contentView.frame), 37)];
        self.valueLabel.font = [UIFont fontWithName:kFontNameAvenirNextRegular size:30];
        self.valueLabel.textColor = [UIColor ftGreenMoneyColor];
        self.valueLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.valueLabel];
        
        self.signImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"money_sign"]];
        [self.contentView addSubview:self.signImageView];
        
        self.leaguesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 47, CGRectGetWidth(self.contentView.frame), 20)];
        self.leaguesLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:12];
        self.leaguesLabel.textColor = [UIColor colorWithRed:141/255.f green:151/255.f blue:144/255.f alpha:0.60];
        self.leaguesLabel.textAlignment = NSTextAlignmentCenter;
        self.leaguesLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.leaguesLabel];
        
        self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"goto"]];
        self.arrowImageView.center = CGPointMake(CGRectGetWidth(self.contentView.frame) - 20, 40.5);
        [self.contentView addSubview:self.arrowImageView];
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 80.5, CGRectGetWidth(self.contentView.frame), 0.5)];
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
