//
//  NSParagraphStyle+AlignmentCenter.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/23/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "NSParagraphStyle+AlignmentCenter.h"

#pragma mark NSParagraphStyle (AlignmentCenter)

@implementation NSParagraphStyle (AlignmentCenter)

#pragma mark - Class Methods

+ (NSParagraphStyle *)defaultCenterAlignmentParagraphStyle {
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    return paragraphStyle;
}

@end
