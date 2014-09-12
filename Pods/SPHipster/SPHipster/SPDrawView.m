//
//  SPDrawView.m
//  SPHipsterDemo
//
//  Created by Fernando Saragoça on 1/21/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "SPDrawView.h"

@interface SPDrawView ()

@property (copy, nonatomic) void (^drawRectBlock)(CGRect rect);

@end

#pragma mark SPDrawView

@implementation SPDrawView

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
    self.backgroundColor = [UIColor clearColor];
}

- (void)setDrawRectBlock:(void (^)(CGRect rect))drawBlock {
    _drawRectBlock = [drawBlock copy];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (self.drawRectBlock) self.drawRectBlock(rect);
}

@end
