//
//  UIView+Frame.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/28/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "UIView+Frame.h"

#pragma mark UIView (Frame)

@implementation UIView (Frame)

#pragma mark - Getters/Setters

- (CGFloat)frameX {
    return CGRectGetMinX(self.frame);
}

- (CGFloat)frameY {
    return CGRectGetMinY(self.frame);
}

- (CGFloat)frameWidth {
    return CGRectGetWidth(self.frame);
}

- (CGFloat)frameHeight {
    return CGRectGetHeight(self.frame);
}

- (void)setFrameX:(CGFloat)frameX {
    CGRect frame = self.frame;
    frame.origin.x = frameX;
    self.frame = frame;
}

- (void)setFrameY:(CGFloat)frameY {
    CGRect frame = self.frame;
    frame.origin.y = frameY;
    self.frame = frame;
}

- (void)setFrameWidth:(CGFloat)frameWidth {
    CGRect frame = self.frame;
    frame.size.width = frameWidth;
    self.frame = frame;
}

- (void)setFrameHeight:(CGFloat)frameHeight {
    CGRect frame = self.frame;
    frame.size.height = frameHeight;
    self.frame = frame;
}

@end
