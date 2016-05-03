//
//  UIView+Frame.m
//  PlayKids
//
//  Created by Leonardo Formaggio on 5/12/15.
//  Copyright (c) 2015 Movile. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

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

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

@end
