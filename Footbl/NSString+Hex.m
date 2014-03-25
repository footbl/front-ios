//
//  NSString+Hex.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/25/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "NSString+Hex.h"

#pragma mark NSString (Hex)

@implementation NSString (Hex)

#pragma mark - Class Methods

+ (NSString *)randomHexStringWithLength:(NSInteger)length {
    NSMutableString *hex = [@"" mutableCopy];
    while (hex.length < length) {
        NSInteger baseInt = arc4random() % 16;
        [hex appendFormat:@"%X", baseInt];
    }
    return [NSString stringWithString:hex];
}

@end
