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
    FootblColorCellSeparator,
    FootblColorCellMatchPot,
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

extern NSString * const kFontNameAvenirNextDemiBold;
extern NSString * const kFontNameAvenirNextMedium;
extern NSString * const kFontNameAvenirNextRegular;
extern NSString * const kFontNameBlack;
extern NSString * const kFontNameLight;
extern NSString * const kFontNameMedium;
extern NSString * const kFontNameSystemLight;
extern NSString * const kFontNameSystemMedium;

@interface FootblAppearance : NSObject

+ (UIColor *)colorForView:(FootblView)footblView;
+ (CGFloat)speedForAnimation:(FootblAnimation)animation;

@end

@interface UIColor (FootblColor)

+ (UIColor *)ftGreenGrassColor;
+ (UIColor *)ftGreenLiveColor;
+ (UIColor *)ftGreenMoneyColor;
+ (UIColor *)ftRedStakeColor;
+ (UIColor *)ftBlueReturnColor;
+ (UIColor *)ftSubtitleColor;

@end