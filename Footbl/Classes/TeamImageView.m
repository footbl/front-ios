//
//  TeamImageView.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/28/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <objc/runtime.h>

#import "TeamImageView.h"

@interface TeamImageView ()

@property (nonatomic, strong) UIImage *originalImage;

@end

@interface UIImage (TintColor)

- (NSOperation *)imageWithTintColor:(UIColor *)tintColor completion:(void (^)(UIImage *image))completion;

@end

#pragma mark TintedImageView

@implementation TeamImageView

#pragma mark - Getters/Setters

- (void)setImage:(UIImage *)image {
    self.originalImage = image;
    
    if ([self.tintColor isEqual:[UIColor clearColor]]) {
        [super setImage:image];
    } else {
        [self.operation cancel];
        
        self.operation = [image imageWithTintColor:self.tintColor completion:^(UIImage *image) {
            [super setImage:image];
        }];
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    
    if ([self.tintColor isEqual:[UIColor clearColor]]) {
        [super setImage:self.originalImage];
    } else {
        [self.operation cancel];
        
        self.operation = [self.originalImage imageWithTintColor:self.tintColor completion:^(UIImage *image) {
            [super setImage:image];
        }];
    }
}

#pragma mark - Instance Methods

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tintColor = [UIColor clearColor];
    }
    return self;
}

@end

#pragma mark UIImage (TintColor)

@implementation UIImage (TintColor)

#pragma mark - Class Methods

+ (NSOperationQueue *)queue {
    static NSOperationQueue *queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[NSOperationQueue alloc] init];
        queue.name = @"com.footbl.queue.image";
    });
    return queue;
}

#pragma mark - Instace Methods

- (NSOperation *)imageWithTintColor:(UIColor *)tintColor completion:(void (^)(UIImage *))completion {
    if (completion) {
        NSBlockOperation *operation = [[NSBlockOperation alloc] init];
        __weak typeof(operation) weakOperation = operation;
        [operation addExecutionBlock:^{
            CGRect frame = CGRectZero;
            frame.size = self.size;
            UIGraphicsBeginImageContextWithOptions(frame.size, NO, self.scale);
            
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
            
            if (weakOperation.isCancelled) {
                return;
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (!weakOperation.isCancelled) {
                    completion(image);
                }
            }];
        }];
        
        [self.class.queue addOperation:operation];
        
        return operation;
    }
    
    return nil;
}

@end