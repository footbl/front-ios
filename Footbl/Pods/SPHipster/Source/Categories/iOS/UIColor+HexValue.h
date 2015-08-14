//
//  UIColor+HexValue.h
//  SPHipster
//
//  Created by Fernando Saragoça on 1/23/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexValue)

+ (UIColor *)colorWithHex:(NSString *)hex alpha:(CGFloat)alpha;

@end
