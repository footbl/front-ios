//
//  FootblAppearance.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "FootblAppearance.h"

NSTimeInterval FTBAnimationDuration		= 0.2;

NSString * const kFontNameAvenirNextDemiBold = @"AvenirNext-DemiBold";
NSString * const kFontNameAvenirNextMedium = @"AvenirNext-Medium";
NSString * const kFontNameAvenirNextRegular = @"AvenirNext-Regular";
NSString * const kFontNameBlack = @"Avenir-Black";
NSString * const kFontNameLight = @"Avenir-Light";
NSString * const kFontNameMedium = @"Avenir-Medium";
NSString * const kFontNameSystemLight = @"HelveticaNeue-Light";
NSString * const kFontNameSystemMedium = @"HelveticaNeue-Medium";

UIColor *UIColorMake(NSUInteger red, NSUInteger green, NSUInteger blue, CGFloat alpha) {
    return [UIColor colorWithRed:(red / 255.f) green:(green / 255.f) blue:(blue / 255.f) alpha:alpha];
}

@implementation UIColor (FootblColor)

+ (UIColor *)ftb_viewBackgroundColor {
	return [UIColor whiteColor];
}

+ (UIColor *)ftb_viewMatchBackgroundColor {
	return UIColorMake(239, 244, 240, 1);
}

+ (UIColor *)ftb_cellBackgroundColor {
	return [UIColor whiteColor];
}

+ (UIColor *)ftb_cellMatchBackgroundColor {
	return UIColorMake(239, 244, 240, 1);
}

+ (UIColor *)ftb_cellSeparatorColor {
	return UIColorMake(2, 2, 2, 0.15);
}

+ (UIColor *)ftb_cellMatchPotColor {
	return UIColorMake(93, 107, 97, 0.7);
}

+ (UIColor *)ftb_tabBarColor {
	return [UIColor colorWithWhite:1.00 alpha:0.98];
}

+ (UIColor *)ftb_tabBarSeparatorColor {
	return UIColorMake(228, 228, 228, 1);
}

+ (UIColor *)ftb_tabBarTintColor {
	return [UIColor ftb_greenGrassColor];
}

+ (UIColor *)ftb_navigationBarColor {
	return [UIColor colorWithWhite:1.00 alpha:FBTweakValue(@"UI", @"Navigation Bar", @"Alpha", 0.95, 0.8, 1.0)];
}

+ (UIColor *)ftb_navigationBarSeparatorColor {
	return UIColorMake(228, 228, 228, 1);
}

+ (UIColor *)ftb_greenGrassColor {
    return UIColorMake(0, 169, 72, 1);
}

+ (UIColor *)ftb_greenLiveColor {
    return UIColorMake(50, 214, 120, 1);
}

+ (UIColor *)ftb_greenMoneyColor {
    return UIColorMake(43, 202, 114, 1);
}

+ (UIColor *)ftb_redStakeColor {
    return UIColorMake(227, 86, 78, 1);
}

+ (UIColor *)ftb_blueReturnColor {
    return UIColorMake(89, 186, 235, 1);
}

+ (UIColor *)ftb_subtitleColor {
    return UIColorMake(156, 164, 158, 1);
}

@end