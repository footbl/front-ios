//
//  UIView+Shake.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/3/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "UIView+Shake.h"

#pragma mark UIView (Shake)

@implementation UIView (Shake)

#pragma mark - Instance Methods

- (void)shake {
    CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [shakeAnimation setToValue:[NSNumber numberWithFloat:0.0f]];
    [shakeAnimation setFromValue:[NSNumber numberWithDouble:M_PI/64]];
    [shakeAnimation setDuration:0.1];
    [shakeAnimation setAutoreverses:YES];
    [self.layer addAnimation:shakeAnimation forKey:@"shakeAnimation"];
}

@end
