//
//  FootblAppearance.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "FootblAppearance.h"

#pragma mark FootblAppearance

@implementation FootblAppearance

#pragma mark - Class Methods

+ (UIColor *)colorForView:(FootblView)footblView {
    switch (footblView) {
        case FootblColorCellBackground:
        case FootblColorNavigationBar:
        case FootblColorTabBar:
        case FootblColorViewBackground:
            return [UIColor whiteColor];
        case FootblColorCellMatchBackground:
        case FootblColorViewMatchBackground:
            return [UIColor colorWithRed:0.94 green:0.96 blue:0.95 alpha:1];
        case FootblColorTabBarTint:
            return [UIColor colorWithRed:0.09 green:0.58 blue:0.29 alpha:1];
    }
}

+ (CGFloat)speedForAnimation:(FootblAnimation)animation {
    switch (animation) {
        case FootblAnimationDefault:
            return 0.2f;
        case FootblAnimationTabBar:
            return 0.2f;
    }
}

#pragma mark - Instance Methods

@end
