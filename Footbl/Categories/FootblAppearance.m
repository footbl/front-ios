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

@implementation UIColor (FootblColor)

+ (UIColor *)ftb_viewBackgroundColor {
	return [UIColor whiteColor];
}

+ (UIColor *)ftb_viewMatchBackgroundColor {
	return [UIColor colorWithRed:239/255.f green:244/255.f blue:240/255.f alpha:1.00];
}

+ (UIColor *)ftb_cellBackgroundColor {
	return [UIColor whiteColor];
}

+ (UIColor *)ftb_cellMatchBackgroundColor {
	return [UIColor colorWithRed:239/255.f green:244/255.f blue:240/255.f alpha:1.00];
}

+ (UIColor *)ftb_cellSeparatorColor {
	return [UIColor colorWithRed:2.0/255.f green:2.0/255.f blue:2.0/255.f alpha:0.15];
}

+ (UIColor *)ftb_cellMatchPotColor {
	return [UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:0.70];
}

+ (UIColor *)ftb_tabBarColor {
	return [UIColor colorWithWhite:1.00 alpha:0.98];
}

+ (UIColor *)ftb_tabBarSeparatorColor {
	return [UIColor colorWithRed:228/255.f green:228/255.f blue:228/255.f alpha:1.00];
}

+ (UIColor *)ftb_tabBarTintColor {
	return [UIColor ftb_greenGrassColor];
}

+ (UIColor *)ftb_navigationBarColor {
	return [UIColor colorWithWhite:1.00 alpha:FBTweakValue(@"UI", @"Navigation Bar", @"Alpha", 0.95, 0.8, 1.0)];
}

+ (UIColor *)ftb_navigationBarSeparatorColor {
	return [UIColor colorWithRed:228/255.f green:228/255.f blue:228/255.f alpha:1.00];
}

+ (UIColor *)ftb_greenGrassColor {
    return [UIColor colorWithRed:0.0/255.f green:169/255.f blue:72./255.f alpha:1.00];
}

+ (UIColor *)ftb_greenLiveColor {
    return [UIColor colorWithRed:50./255.f green:214/255.f blue:120/255.f alpha:1.00];
}

+ (UIColor *)ftb_greenMoneyColor {
    return [UIColor colorWithRed:43./255.f green:202/255.f blue:114/255.f alpha:1.00];
}

+ (UIColor *)ftb_redStakeColor {
    return [UIColor colorWithRed:227/255.f green:86./255.f blue:78./255.f alpha:1.00];
}

+ (UIColor *)ftb_blueReturnColor {
    return [UIColor colorWithRed:89./255.f green:186/255.f blue:235/255.f alpha:1.00];
}

+ (UIColor *)ftb_subtitleColor {
    return [UIColor colorWithRed:156/255.f green:164/255.f blue:158/255.f alpha:1.00];
}

@end