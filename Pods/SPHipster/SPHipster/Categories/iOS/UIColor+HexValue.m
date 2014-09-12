//
//  UIColor+HexValue.m
//  SPHipster
//
//  Created by Fernando Saragoça on 1/23/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "UIColor+HexValue.h"

#pragma mark UIColor (HexValue)

@implementation UIColor (HexValue)

#pragma mark - Class Methods

+ (UIColor *)colorWithHex:(NSString *)hex alpha:(CGFloat)alpha {
    unsigned int hexint = 0;
    
    NSScanner *scanner = [NSScanner scannerWithString:hex];
    scanner.charactersToBeSkipped = [NSCharacterSet characterSetWithCharactersInString:@"#"];
    [scanner scanHexInt:&hexint];
    
    UIColor *color = [UIColor colorWithRed:((CGFloat)((hexint & 0xFF0000) >> 16)) / 255.f green:((CGFloat)((hexint & 0xFF00) >> 8)) / 255.f blue:((CGFloat)(hexint & 0xFF)) / 255.f alpha:alpha];
    return color;
}

@end
