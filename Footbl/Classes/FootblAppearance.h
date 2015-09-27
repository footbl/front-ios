//
//  FootblAppearance.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSTimeInterval FTBAnimationDuration;

extern NSString * const kFontNameAvenirNextDemiBold;
extern NSString * const kFontNameAvenirNextMedium;
extern NSString * const kFontNameAvenirNextRegular;
extern NSString * const kFontNameBlack;
extern NSString * const kFontNameLight;
extern NSString * const kFontNameMedium;
extern NSString * const kFontNameSystemLight;
extern NSString * const kFontNameSystemMedium;

@interface UIColor (FootblColor)

+ (UIColor *)ftb_viewBackgroundColor;
+ (UIColor *)ftb_viewMatchBackgroundColor;
+ (UIColor *)ftb_cellBackgroundColor;
+ (UIColor *)ftb_cellMatchBackgroundColor;
+ (UIColor *)ftb_cellSeparatorColor;
+ (UIColor *)ftb_cellMatchPotColor;
+ (UIColor *)ftb_tabBarColor;
+ (UIColor *)ftb_tabBarSeparatorColor;
+ (UIColor *)ftb_tabBarTintColor;
+ (UIColor *)ftb_navigationBarColor;
+ (UIColor *)ftb_navigationBarSeparatorColor;

+ (UIColor *)ftb_greenGrassColor;
+ (UIColor *)ftb_greenLiveColor;
+ (UIColor *)ftb_greenMoneyColor;
+ (UIColor *)ftb_redStakeColor;
+ (UIColor *)ftb_blueReturnColor;
+ (UIColor *)ftb_subtitleColor;

@end