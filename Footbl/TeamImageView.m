//
//  TeamImageView.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/28/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TeamImageView.h"

@interface TeamImageView ()

@property (strong, nonatomic) UIImage *originalImage;

@end

@interface UIImage (TintColor)

- (UIImage *)imageWithTintColor:(UIColor *)tintColor;

@end

#pragma mark TintedImageView

@implementation TeamImageView

#pragma mark - Getters/Setters

- (void)setImage:(UIImage *)image {
    self.originalImage = image;
    
    if ([self.tintColor isEqual:[UIColor clearColor]]) {
        [super setImage:image];
    } else {
        [super setImage:[image imageWithTintColor:self.tintColor]];
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    
    if ([self.tintColor isEqual:[UIColor clearColor]]) {
        [super setImage:self.originalImage];
    } else {
        [super setImage:[self.originalImage imageWithTintColor:self.tintColor]];
    }
}

#pragma mark - Instance Methods

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.tintColor = [UIColor clearColor];
    }
    return self;
}

@end

#pragma mark UIImage (TintColor)

@implementation UIImage (TintColor)

#pragma mark - Instace Methods

- (UIImage *)imageWithTintColor:(UIColor *)tintColor {
    CGRect frame = CGRectMake(0.f, 0.f, self.size.width, self.size.height);
    UIGraphicsBeginImageContext(frame.size);
    
    // Get the graphic context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw the image
    [self drawInRect:frame];
    
    // Converting a UIImage to a CGImage flips the image,
    // so apply a upside-down translation
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // Set the fill color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextSetFillColorSpace(context, colorSpace);
    
    // Set the mask to only tint non-transparent pixels
    CGContextClipToMask(context, frame, self.CGImage);
    
    
    // Set the fill color
    CGContextSetFillColorWithColor(context, tintColor.CGColor);
    UIRectFillUsingBlendMode(frame, kCGBlendModeColor);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Release memory
    CGColorSpaceRelease(colorSpace);
    
    return image;
}

@end