//
//  UILabel+Image.m
//  Footbl
//
//  Created by Leonardo Formaggio on 3/20/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import "UILabel+Image.h"

@implementation UILabel (Image)

- (UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRelease(context);
    UIGraphicsEndImageContext();
    return image;
}

@end
