//
//  FootblAppearance.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FootblView) {
    FootblColorViewBackground,
    FootblColorViewMatchBackground,
    FootblColorCellBackground,
    FootblColorCellMatchBackground,
    FootblColorTabBar,
    FootblColorTabBarSeparator,
    FootblColorTabBarTint,
    FootblColorNavigationBar,
    FootblColorNavigationBarSeparator
};

typedef NS_ENUM(NSInteger, FootblAnimation) {
    FootblAnimationDefault,
    FootblAnimationTabBar
};

@interface FootblAppearance : NSObject

+ (UIColor *)colorForView:(FootblView)footblView;
+ (CGFloat)speedForAnimation:(FootblAnimation)animation;

@end

@interface UIColor (FootblColor)

+ (UIColor *)ftVerdeGramadoColor;

@end