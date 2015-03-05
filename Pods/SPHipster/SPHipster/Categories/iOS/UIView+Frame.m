//
//  UIView+Frame.m
//  SPHipster iOS Example
//
//  Created by Fernando Saragoca on 8/30/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "UIView+Frame.h"

#pragma mark UIView (Frame)

@implementation UIView (Frame)

#pragma mark - Getters/Setters

- (CGFloat)x {
    return CGRectGetMinX(self.frame);
}

- (CGFloat)y {
    return CGRectGetMinY(self.frame);
}

- (CGFloat)width {
    return CGRectGetWidth(self.frame);
}

- (CGFloat)height {
    return CGRectGetHeight(self.frame);
}

- (CGFloat)midX {
    return CGRectGetMidX(self.frame);
}

- (CGFloat)midY {
    return CGRectGetMidY(self.frame);
}

- (CGFloat)maxX {
	return CGRectGetMaxX(self.frame);
}

- (CGFloat)maxY {
	return CGRectGetMaxY(self.frame);
}

- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (void)setMidX:(CGFloat)midX {
    CGPoint center = self.center;
    center.x = midX;
    self.center = center;
}

- (void)setMidY:(CGFloat)midY {
    CGPoint center = self.center;
    center.y = midY;
    self.center = center;
}

- (void)setMaxX:(CGFloat)maxX {
	self.x = maxX - self.width;
}

- (void)setMaxY:(CGFloat)maxY {
	self.y = maxY - self.height;
}

@end
