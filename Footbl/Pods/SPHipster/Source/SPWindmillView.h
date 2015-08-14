//
//  SPWindmillView.h
//  SPHipsterDemo
//
//  Created by Fernando Saragoça on 1/21/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SPWindmillViewColorScheme) {
    SPWindmillViewColorSchemeOriginal,
    SPWindmillViewColorSchemeOrange,
    SPWindmillViewColorSchemeRedGray,
    SPWindmillViewColorSchemeRedBlue,
    SPWindmillViewColorSchemeBlueAqua,
    SPWindmillViewColorSchemeMac,
    SPWindmillViewColorSchemeZZZPurple,
    SPWindmillViewColorSchemeZZZRed,
    SPWindmillViewColorSchemeZZZGreen,
    SPWindmillViewColorSchemeZZZBlue,
    SPWindmillViewColorSchemeZZZYellow
};

typedef NS_ENUM(NSUInteger, SPWindmillViewTextStyle) {
    SPWindmillViewTextStyleLowerCase,
    SPWindmillViewTextStyleUpperCase
};

typedef NS_ENUM(NSUInteger, SPWindmillViewFontStyle) {
    SPWindmillViewFontStyleCondensed,
    SPWindmillViewFontStyleRegular
};

@interface SPWindmillView : UIView

@property (assign, nonatomic) SPWindmillViewColorScheme colorScheme;
@property (assign, nonatomic) SPWindmillViewTextStyle textStyle;
@property (assign, nonatomic) SPWindmillViewFontStyle fontStyle;
@property (assign, nonatomic) CGFloat lineWidth;
@property (assign, nonatomic) CGFloat logoSize;
@property (assign, nonatomic) CGFloat margin;
@property (assign, nonatomic) CGFloat rotationsPerSecond;
@property (assign, nonatomic) BOOL shouldDrawLabel;
@property (strong, nonatomic) NSMutableDictionary *textAttributes;

- (void)loadColorForSquare:(UIColor *__autoreleasing *)squareColor rhombusA:(UIColor *__autoreleasing *)rhombusA rhombusB:(UIColor *__autoreleasing *)rhombusB line:(UIColor *__autoreleasing *)line NS_REQUIRES_SUPER;
- (void)startAnimation;
- (void)stopAnimation;

@end
