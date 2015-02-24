//
//  FootblLabel.h
//  Footbl
//
//  Created by Fernando Saragoça on 7/30/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FootblLabel : UILabel

@property (strong, nonatomic) UIColor *firstLineTextColor;
@property (strong, nonatomic) UIFont *firstLineFont;
@property (assign, nonatomic) CGFloat lineHeightMultiple;

@end
