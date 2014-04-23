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
        case FootblColorViewBackground:
            return [UIColor whiteColor];
        case FootblColorCellMatchBackground:
        case FootblColorViewMatchBackground:
            return [UIColor colorWithRed:0.94 green:0.96 blue:0.95 alpha:1];
        case FootblColorNavigationBar:
            return [UIColor colorWithWhite:1.00 alpha:0.80];
        case FootblColorTabBar:
            return [UIColor colorWithWhite:1.00 alpha:0.98];
        case FootblColorTabBarTint:
            return [UIColor ftVerdeGramadoColor];
        case FootblColorTabBarSeparator:
        case FootblColorNavigationBarSeparator:
            return [UIColor colorWithRed:228/255.f green:228/255.f blue:228/255.f alpha:1.0];
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

#pragma mark UIColor (FootblColor)

@implementation UIColor (FootblColor)

#pragma mark - Class Methods

+ (UIColor *)ftVerdeGramadoColor {
    return [UIColor colorWithRed:0.00/255.f green:169/255.f blue:72/255.f alpha:1];
}

@end