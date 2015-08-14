//
//  UILabel+MaxFontSize.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/28/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "UILabel+MaxFontSize.h"

#pragma mark UILabel (MaxFontSize)

@implementation UILabel (MaxFontSize)

#pragma mark - Instance Methods

- (CGFloat)maxFontSizeToFitBounds {
    UIFont *font = self.font;
    CGSize size = [self.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.frame), INT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:[NSStringDrawingContext new]].size;
    while (size.height > CGRectGetHeight(self.frame)) {
        font = [UIFont fontWithName:font.fontName size:font.pointSize - 0.5];
        size = [self.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.frame), INT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:[NSStringDrawingContext new]].size;
    }
    return font.pointSize;
}

@end
