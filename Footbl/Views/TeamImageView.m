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

@interface UIImage (Mono)

- (NSOperation *)tonalImage:(void (^)(UIImage *image))completion;

@end

#pragma mark TintedImageView

@implementation TeamImageView

#pragma mark - Getters/Setters

- (void)setImage:(UIImage *)image {
    self.originalImage = image;
    
    if (self.isEnabled) {
        [super setImage:image];
    } else {
        [self.operation cancel];
        self.operation = [image tonalImage:^(UIImage *image) {
            [super setImage:image];
        }];
    }
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    
    if (enabled) {
        [super setImage:self.originalImage];
    } else {
        [self.operation cancel];
        self.operation = [self.originalImage tonalImage:^(UIImage *image) {
            [super setImage:image];
        }];
    }
}

- (void)setAlpha:(CGFloat)alpha {
    [super setAlpha:alpha];
    
    self.enabled = (alpha == 1);
}

#pragma mark - Instance Methods

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _enabled = YES;
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

+ (NSCache *)cache {
    static NSCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
        cache.name = @"com.footbl.cache.image";
    });
    return cache;
}

#pragma mark - Instace Methods

- (id)key {
    return @(self.hash);
}

- (NSOperation *)tonalImage:(void (^)(UIImage *))completion {
    if (!completion) {
        return nil;
    }
    
    UIImage *cachedImage = [self.class.cache objectForKey:self.key];
    if (cachedImage) {
        completion(cachedImage);
        return nil;
    }
    
    NSBlockOperation *operation = [[NSBlockOperation alloc] init];
    __weak typeof(operation) weakOperation = operation;
    [operation addExecutionBlock:^{
        CIContext *context = [CIContext contextWithOptions:nil];
        CIImage *inputImage = [[CIImage alloc] initWithImage:self];
        CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectTonal" withInputParameters:@{kCIInputImageKey: inputImage}];
        CGImageRef CGImage = [context createCGImage:filter.outputImage fromRect:inputImage.extent];
        UIImage *image = [UIImage imageWithCGImage:CGImage];
        
        [self.class.cache setObject:image forKey:self.key];
        
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

@end