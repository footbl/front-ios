//
//  NSURLRequest+FTRequestOptions.m
//  Footbl
//
//  Created by Fernando Saragoça on 8/9/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <objc/runtime.h>
#import "NSURLRequest+FTRequestOptions.h"

#pragma mark NSURLRequest (FTRequestOptions)

@implementation NSURLRequest (FTRequestOptions)

#pragma mark - Getters/Setters

- (FTRequestOptions)options {
    return (FTRequestOptions)[objc_getAssociatedObject(self, @selector(options)) integerValue];
}

- (void)setOptions:(FTRequestOptions)options {
    objc_setAssociatedObject(self, @selector(options), @(options), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)page {
    return [objc_getAssociatedObject(self, @selector(page)) integerValue];
}

- (void)setPage:(NSInteger)page {
    objc_setAssociatedObject(self, @selector(page), @(page), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
