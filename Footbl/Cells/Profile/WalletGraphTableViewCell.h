//
//  WalletGraphTableViewCell.h
//  Footbl
//
//  Created by Fernando Saragoça on 7/18/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateTableViewCell.h"

@class User;

@interface WalletGraphTableViewCell : TemplateTableViewCell

@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) UILabel *roundsLabel;

@end
