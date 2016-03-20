//
//  WalletTableViewCell.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/20/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateTableViewCell.h"

@interface WalletTableViewCell : TemplateTableViewCell

@property (copy, nonatomic) NSString *valueText;
#warning Remove this
@property (strong, nonatomic) UILabel *leaguesLabel;
@property (strong, nonatomic) UIImageView *arrowImageView;

@end
