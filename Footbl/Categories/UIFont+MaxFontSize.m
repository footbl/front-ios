//
//  UIFont+MaxFontSize.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/15/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <objc/runtime.h>

#import "UIFont+MaxFontSize.h"
#import "UILabel+MaxFontSize.h"

#pragma mark UIFont (MaxFontSize)

@implementation UIFont (MaxFontSize)

#pragma mark - Class Methods

+ (void)setMaxFontSizeToFitBoundsInLabels:(NSArray *)labels {
    if (labels.count == 0) {
        return;
    }
    
    NSNumber *originalSize = objc_getAssociatedObject(labels.firstObject, @selector(setMaxFontSizeToFitBoundsInLabels:));
    NSString *fontName = [labels.firstObject font].fontName;
    
    if (!originalSize) {
        originalSize = @([labels.firstObject font].pointSize);
        objc_setAssociatedObject(labels.firstObject, @selector(setMaxFontSizeToFitBoundsInLabels:), originalSize, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    CGFloat maxSize = 0;
    for (UILabel *label in labels) {
        label.font = [UIFont fontWithName:label.font.fontName size:originalSize.floatValue];
        if (maxSize == 0) {
            maxSize = [label maxFontSizeToFitBounds];
        } else {
            maxSize = MIN(maxSize, [label maxFontSizeToFitBounds]);
        }
    }
    
    [labels makeObjectsPerformSelector:@selector(setFont:) withObject:[UIFont fontWithName:fontName size:maxSize]];
}

@end
