//
//  UIBezierPath+Rhombus.m
//  SPHipsterDemo
//
//  Created by Fernando Saragoça on 1/21/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "UIBezierPath+Rhombus.h"

#pragma mark UIBezierPath (Rhombus)

@implementation UIBezierPath (Rhombus)

#pragma mark - Class Methods

+ (UIBezierPath *)bezierPathWithRhombusRect:(CGRect)rect lineWidth:(CGFloat)lineWidth {
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (rect.size.width > rect.size.height) {
        CGFloat space = rect.size.width / 2;
        [path moveToPoint:CGPointMake(rect.origin.x + lineWidth * 1.2, rect.origin.y + rect.size.height - lineWidth * 0.5)];
        [path addLineToPoint:CGPointMake(rect.origin.x + space + lineWidth * 0.2, rect.origin.y + lineWidth * 0.5)];
        [path addLineToPoint:CGPointMake(rect.origin.x + space * 2 - lineWidth * 1.2, rect.origin.y + lineWidth * 0.5)];
        [path addLineToPoint:CGPointMake(rect.origin.x + space - lineWidth * 0.2, rect.origin.y + rect.size.height - lineWidth * 0.5)];
    } else {
        CGFloat space = rect.size.height / 2;
        [path moveToPoint:CGPointMake(rect.origin.x + lineWidth * 0.5, rect.origin.y + space - lineWidth * 0.2)];
        [path addLineToPoint:CGPointMake(rect.origin.x + lineWidth * 0.5, rect.origin.y + lineWidth * 1.2)];
        [path addLineToPoint:CGPointMake(rect.origin.x + rect.size.width - lineWidth * 0.5, rect.origin.y + space + lineWidth * 0.2)];
        [path addLineToPoint:CGPointMake(rect.origin.x + rect.size.width - lineWidth * 0.5, rect.origin.y + space * 2 - lineWidth * 1.2)];
    }
    [path closePath];
    
    return path;
}

@end
