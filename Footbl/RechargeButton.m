//
//  RechargeButton.m
//  Footbl
//
//  Created by Fernando Saragoca on 11/20/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "RechargeButton.h"

#pragma mark RechargeButton

@implementation RechargeButton

#pragma mark - Getters/Setters

- (void)setAnimating:(BOOL)animating {
    if (_animating == animating) {
        return;
    }
    
    _animating = animating;
    if (self.numberOfAnimations == 0) {
        self.numberOfAnimations = NSIntegerMax;
    }
    
    [self runAnimation];
}

#pragma mark - Instance Methods

- (void)runAnimation {
    CGFloat alpha = self.alpha == 1 ? 0.3 : 1;
    self.numberOfAnimations --;
    [UIView animateWithDuration:1.0 animations:^{
        self.alpha = alpha;
    } completion:^(BOOL finished) {
        if (alpha < 1 || (self.numberOfAnimations > 0 && self.isAnimating)) {
            [self runAnimation];
        }
    }];
}

@end
