//
//  WalletGraphTableViewCell.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/18/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "User.h"
#import "WalletGraphTableViewCell.h"
#import "WalletGraphView.h"

@interface WalletGraphTableViewCell ()

@property (strong, nonatomic) WalletGraphView *graphView;

@end

#pragma mark WalletGraphTableViewCell

@implementation WalletGraphTableViewCell

#pragma mark - Getters/Setters

- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = dataSource;
    
    self.graphView.dataSource = dataSource;
}

#pragma mark - Instance Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.roundsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 38)];
        self.roundsLabel.font = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:12];
        self.roundsLabel.textColor = [UIColor colorWithRed:141/255.f green:151/255.f blue:144/255.f alpha:1.00];
        self.roundsLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.roundsLabel];
        
        self.graphView = [[WalletGraphView alloc] initWithFrame:CGRectMake(0, 38, CGRectGetWidth(self.frame), 103)];
        self.graphView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.graphView];
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 163.5, CGRectGetWidth(self.contentView.frame), 0.5)];
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
