//
//  WalletGraphTableViewCell.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/18/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

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
        self.roundsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.roundsLabel];
        
        self.graphView = [[WalletGraphView alloc] initWithFrame:CGRectMake(0, 38, CGRectGetWidth(self.frame), 103)];
        self.graphView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.graphView];
    }
    return self;
}

@end
