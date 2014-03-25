//
//  SPWindmillView.m
//  SPHipsterDemo
//
//  Created by Fernando Saragoça on 1/21/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SPBlock.h"
#import "SPDrawView.h"
#import "SPWindmillView.h"
#import "UIBezierPath+Rhombus.h"

@interface SPWindmillView ()

@property (strong, nonatomic, readonly) SPDrawView *windmill;
@property (strong, nonatomic, readonly) CABasicAnimation *rotationAnimation;
@property (strong, nonatomic, readonly) UILabel *titleLabel;
@property (assign, nonatomic) BOOL updatedTextAttributes;

@end

#pragma mark SPWindmillView

@implementation SPWindmillView

static NSString * kRotationAnimationKey = @"kRotationAnimationKey";
static NSString * kSampaName = @"MADE@SAMPA";

#pragma mark - Getters/Setters

@synthesize textAttributes = _textAttributes;

- (void)setLogoSize:(CGFloat)logoSize {
    _logoSize = logoSize;

    [[self windmill] setFrame:CGRectMake(0, 0, [self logoSize], [self logoSize])];
    [[self windmill] setCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)];
    
    [self setNeedsDisplay];
}

- (void)setColorScheme:(SPWindmillViewColorScheme)colorScheme {
    _colorScheme = colorScheme;
    
    [self setNeedsDisplay];
}

- (void)setRotationsPerSecond:(CGFloat)rotationsPerSecond {
    _rotationsPerSecond = rotationsPerSecond;
    
    [[self rotationAnimation] setDuration:1 / [self rotationsPerSecond]];
    [[[self windmill] layer] addAnimation:[self rotationAnimation] forKey:kRotationAnimationKey];
}

- (void)setMargin:(CGFloat)margin {
    _margin = margin;
    
    [self setNeedsDisplay];
}

- (void)setShouldDrawLabel:(BOOL)shouldDrawLabel {
    _shouldDrawLabel = shouldDrawLabel;
    
    [self setNeedsDisplay];
}

- (void)setTextAttributes:(NSMutableDictionary *)textAttributes {
    _textAttributes = textAttributes;
    
    [self setUpdatedTextAttributes:YES];
    
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame {
    if ([self logoSize] == MIN(self.frame.size.width, self.frame.size.height)) {
        [self setLogoSize:MIN(frame.size.width, frame.size.height)];
    }
    
    [super setFrame:frame];
}

- (NSMutableDictionary *)textAttributes {
    if (_textAttributes == nil) {
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        _textAttributes = [@{NSForegroundColorAttributeName : [UIColor colorWithRed:0.494 green:0.506 blue:0.580 alpha:1.000],
                             NSFontAttributeName : [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:[self preferredTextSize]],
                             NSParagraphStyleAttributeName : paragraphStyle} mutableCopy];
    }
    
    return _textAttributes;
}

#pragma mark - Instance Methods

- (id)init {
    self = [super init];
    if (self) {
        [self sharedInitialization];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInitialization];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInitialization];
    }
    return self;
}

- (void)sharedInitialization {
    [self setBackgroundColor:[UIColor clearColor]];
    [self setColorScheme:SPWindmillViewColorSchemeOriginal];
    [self setMargin:0];
    [self setLineWidth:1];
    [self setLogoSize:MIN(self.frame.size.width, self.frame.size.height)];
    [self setShouldDrawLabel:YES];
    [self setUpdatedTextAttributes:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startRotationAnimation) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopRotationAnimation) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    CGFloat speed = pow([self logoSize], -0.15);
    [self setRotationsPerSecond:speed * (speed * 1.8)];
    
    _windmill = [[SPDrawView alloc] initWithFrame:CGRectMake(0, 0, [self logoSize], [self logoSize])];
    [[self windmill] setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [[self windmill] setCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)];
    [[self windmill] setDrawRectBlock:^(CGRect rect) {
        [self drawWindmillRect:rect];
    }];
    [self addSubview:[self windmill]];
    
    _rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [[self rotationAnimation] setFromValue:@(0)];
    [[self rotationAnimation] setToValue:@(2 * M_PI)];
    [[self rotationAnimation] setDuration:1 / [self rotationsPerSecond]];
    [[self rotationAnimation] setRepeatCount:HUGE_VALF];
    [[[self windmill] layer] addAnimation:[self rotationAnimation] forKey:kRotationAnimationKey];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.windmill.frame) + 10, self.frame.size.width, 40)];
    [[self titleLabel] setAttributedText:[[NSAttributedString alloc] initWithString:kSampaName attributes:[self textAttributes]]];
    [self addSubview:[self titleLabel]];
}

- (void)drawRect:(CGRect)rect {
    if (![self updatedTextAttributes]) {
        _textAttributes = nil;
    }

    CGSize size = [kSampaName sizeWithAttributes:[self textAttributes]];
    [[self titleLabel] setAttributedText:[[NSAttributedString alloc] initWithString:kSampaName attributes:[self textAttributes]]];
    [[self titleLabel] setFrame:CGRectMake(0, CGRectGetMaxY(self.windmill.frame) - [self margin], self.frame.size.width, size.height)];
    
    if ([self shouldDrawLabel]) {
        [[self titleLabel] setAlpha:1];
        [[self windmill] setCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 - size.height / 2)];
    } else {
        [[self titleLabel] setAlpha:0];
        [[self windmill] setCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)];
    }
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    [[self windmill] setNeedsDisplay];
}

- (void)startRotationAnimation {
    [[[self windmill] layer] addAnimation:[self rotationAnimation] forKey:kRotationAnimationKey];
}

- (void)stopRotationAnimation {
    [[[self windmill] layer] removeAnimationForKey:kRotationAnimationKey];
}

- (CGFloat)preferredTextSize {
    return MAX(12, round([self logoSize] / 8));
}

- (void)drawWindmillRect:(CGRect)rect {
    UIColor *squareColor, *rhombusAColor, *rhombusBColor, *lineColor;
    [self loadColorForSquare:&squareColor rhombusA:&rhombusAColor rhombusB:&rhombusBColor line:&lineColor];
    
    CGFloat spacing = ([self logoSize] - [self margin] * 2) / 4;
    CGFloat margin = [self margin];
    CGFloat lineWidth = [self lineWidth];
    
    if (!lineColor || lineColor == [UIColor clearColor]) {
        lineWidth = 0;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(margin + spacing, margin + spacing * 2)];
    [path addLineToPoint:CGPointMake(margin + spacing * 2, margin + spacing)];
    [path addLineToPoint:CGPointMake(margin + spacing * 3, margin + spacing * 2)];
    [path addLineToPoint:CGPointMake(margin + spacing * 2, margin + spacing * 3)];
    [squareColor setFill];
    [path fill];
    
    void(^paint)(UIBezierPath *path, UIColor *color) = ^(UIBezierPath *path, UIColor *color) {
        if (lineColor && lineColor != [UIColor clearColor]) {
            [path setLineWidth:[self lineWidth]];
            [lineColor setStroke];
            [path stroke];
        }
        
        [color setFill];
        [path fill];
    };
    
    paint([UIBezierPath bezierPathWithRhombusRect:CGRectIntegral(CGRectMake(margin + [self lineWidth] * 0.5, margin + spacing, spacing * 2, spacing)) lineWidth:[self lineWidth]], rhombusAColor);
    
    paint([UIBezierPath bezierPathWithRhombusRect:CGRectIntegral(CGRectMake(margin + spacing * 2, margin + [self lineWidth] * 0.5, spacing, spacing * 2)) lineWidth:[self lineWidth]], rhombusBColor);
    
    paint([UIBezierPath bezierPathWithRhombusRect:CGRectIntegral(CGRectMake(margin + spacing * 2 - [self lineWidth] * 0.5, margin + spacing * 2, spacing * 2, spacing)) lineWidth:[self lineWidth]], rhombusAColor);
    
    paint([UIBezierPath bezierPathWithRhombusRect:CGRectIntegral(CGRectMake(margin + spacing, margin + spacing * 2 - [self lineWidth] * 0.5, spacing, spacing * 2)) lineWidth:[self lineWidth]], rhombusBColor);
}

- (void)loadColorForSquare:(UIColor *__autoreleasing *)squareColor rhombusA:(UIColor *__autoreleasing *)rhombusA rhombusB:(UIColor *__autoreleasing *)rhombusB line:(UIColor *__autoreleasing *)line {
    switch ([self colorScheme]) {
        case SPWindmillViewColorSchemeOrange:
            *squareColor = [UIColor colorWithRed:0.992 green:0.471 blue:0.165 alpha:1.000];
            *rhombusA = [UIColor colorWithRed:0.992 green:0.624 blue:0.349 alpha:1.000];
            *rhombusB = [UIColor colorWithRed:0.996 green:0.769 blue:0.247 alpha:1.000];
            *line = [UIColor clearColor];
            break;
        case SPWindmillViewColorSchemeRedBlue:
            *squareColor = [UIColor colorWithRed:0.094 green:0.161 blue:0.255 alpha:1.000];
            *rhombusA = [UIColor colorWithRed:0.153 green:0.639 blue:0.988 alpha:1.000];
            *rhombusB = [UIColor colorWithRed:0.859 green:0.267 blue:0.271 alpha:1.000];
            *line = [UIColor clearColor];
            break;
        case SPWindmillViewColorSchemeRedGray:
            *squareColor = [UIColor colorWithRed:0.698 green:0.125 blue:0.141 alpha:1.000];
            *rhombusA = [UIColor colorWithRed:0.941 green:0.314 blue:0.322 alpha:1.000];
            *rhombusB = [UIColor colorWithRed:0.482 green:0.549 blue:0.549 alpha:1.000];
            *line = [UIColor clearColor];
            break;
        case SPWindmillViewColorSchemeBlueAqua:
            *squareColor = [UIColor colorWithRed:0.141 green:0.396 blue:0.635 alpha:1.000];
            *rhombusA = [UIColor colorWithRed:0.141 green:0.353 blue:0.600 alpha:1.000];
            *rhombusB = [UIColor colorWithRed:0.439 green:0.733 blue:0.820 alpha:1.000];
            *line = [UIColor clearColor];
            break;
        case SPWindmillViewColorSchemeMac:
            *squareColor = [UIColor colorWithRed:0.702 green:0.827 blue:0.953 alpha:1.000];
            *rhombusA = [UIColor colorWithWhite:1 alpha:0.2];
            *rhombusB = [UIColor clearColor];
            *line = [UIColor colorWithRed:0.616 green:0.780 blue:0.937 alpha:1.000];
            break;
        case SPWindmillViewColorSchemeOriginal:
            *squareColor = [UIColor colorWithRed:0.192 green:0.357 blue:0.486 alpha:1.000];
            *rhombusA = [UIColor colorWithRed:0.494 green:0.506 blue:0.580 alpha:1.000];
            *rhombusB = [UIColor colorWithRed:0.388 green:0.694 blue:0.831 alpha:1.000];
            *line = [UIColor clearColor];
            break;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
