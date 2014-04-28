//
//  FootblAppearance.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "FootblAppearance.h"

NSString * const kFontNameBlack = @"Avenir-Black";
NSString * const kFontNameLight = @"Avenir-Light";
NSString * const kFontNameMedium = @"Avenir-Medium";

#pragma mark FootblAppearance

@implementation FootblAppearance

#pragma mark - Class Methods

+ (UIColor *)colorForView:(FootblView)footblView {
    switch (footblView) {
        case FootblColorCellBackground:
        case FootblColorViewBackground:
            return [UIColor whiteColor];
        case FootblColorCellSeparator:
            return [UIColor colorWithRed:2.0/255.f green:2.0/255.f blue:2.0/255.f alpha:0.15];
        case FootblColorCellMatchPot:
            return [UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:0.70];
        case FootblColorCellMatchBackground:
        case FootblColorViewMatchBackground:
            return [UIColor colorWithRed:239/255.f green:244/255.f blue:240/255.f alpha:1.00];
        case FootblColorNavigationBar:
            return [UIColor colorWithWhite:1.00 alpha:0.80];
        case FootblColorTabBar:
            return [UIColor colorWithWhite:1.00 alpha:0.98];
        case FootblColorTabBarTint:
            return [UIColor ftGreenGrassColor];
        case FootblColorTabBarSeparator:
        case FootblColorNavigationBarSeparator:
            return [UIColor colorWithRed:228/255.f green:228/255.f blue:228/255.f alpha:1.00];
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

+ (UIColor *)ftGreenGrassColor {
    return [UIColor colorWithRed:0.0/255.f green:169/255.f blue:72./255.f alpha:1.00];
}

+ (UIColor *)ftGreenLiveColor {
    return [UIColor colorWithRed:50./255.f green:214/255.f blue:120/255.f alpha:1.00];
}

+ (UIColor *)ftGreenMoneyColor {
    return [UIColor colorWithRed:43./255.f green:202/255.f blue:114/255.f alpha:1.00];
}

+ (UIColor *)ftRedStakeColor {
    return [UIColor colorWithRed:227/255.f green:86./255.f blue:78./255.f alpha:1.00];
}

+ (UIColor *)ftBlueReturnColor {
    return [UIColor colorWithRed:89./255.f green:186/255.f blue:235/255.f alpha:1.00];
}

+ (UIColor *)ftSubtitleColor {
    return [UIColor colorWithRed:156/255.f green:164/255.f blue:158/255.f alpha:1.00];
}

@end