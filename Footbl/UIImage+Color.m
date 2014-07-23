//
//  UIImage+Color.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/23/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "UIImage+Color.h"

#pragma mark UIImage (Color)

@implementation UIImage (Color)

#pragma mark - Class Methods

+ (UIImage *)imageWithColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 0);
    [color setFill];
    UIRectFill(CGRectMake(0, 0, 1, 1));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
