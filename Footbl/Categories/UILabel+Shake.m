//
//  UILabel+Shake.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/7/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

@import ObjectiveC;

#import "UILabel+Shake.h"
#import "UIView+Shake.h"

static NSString * const kLabelShakingKey = @"kLabelShakingKey";

#pragma mark UILabel (Shake)

@implementation UILabel (Shake)

#pragma mark - Instance Methods

- (void)shakeAndChangeColor {
    NSNumber *shaking = objc_getAssociatedObject(self, (__bridge const void *)(kLabelShakingKey));
    if (shaking && [shaking boolValue]) {
        return;
    }
    
    objc_setAssociatedObject(self, (__bridge const void *)(kLabelShakingKey), @YES, OBJC_ASSOCIATION_ASSIGN);
    
    UIColor *originalColor = [self textColor];
    [self shake];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.1f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.layer addAnimation:transition forKey:nil];
    self.textColor = [UIColor colorWithRed:216/255.f green:80./255.f blue:80./255.f alpha:1.00];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CATransition *transition = [CATransition animation];
        transition.duration = 0.2f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        [self.layer addAnimation:transition forKey:nil];
        self.textColor = originalColor;
        
        objc_setAssociatedObject(self, (__bridge const void *)(kLabelShakingKey), nil, OBJC_ASSOCIATION_ASSIGN);
    });
}

@end

#pragma mark UITextField (Shake)

@implementation UITextField (Shake)

#pragma mark - Instance Methods

- (void)shakeAndChangeColor {
    NSNumber *shaking = objc_getAssociatedObject(self, (__bridge const void *)(kLabelShakingKey));
    if (shaking && [shaking boolValue]) {
        return;
    }
    
    objc_setAssociatedObject(self, (__bridge const void *)(kLabelShakingKey), @YES, OBJC_ASSOCIATION_ASSIGN);
    
    UIColor *originalColor = [self textColor];
    [self shake];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.1f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.layer addAnimation:transition forKey:nil];
    self.textColor = [UIColor colorWithRed:216/255.f green:80./255.f blue:80./255.f alpha:1.00];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CATransition *transition = [CATransition animation];
        transition.duration = 0.2f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        [self.layer addAnimation:transition forKey:nil];
        self.textColor = originalColor;
        
        objc_setAssociatedObject(self, (__bridge const void *)(kLabelShakingKey), nil, OBJC_ASSOCIATION_ASSIGN);
    });
}

@end

#pragma mark UITextView (Shake)

@implementation UITextView (Shake)

#pragma mark - Instance Methods

- (void)shakeAndChangeColor {
    NSNumber *shaking = objc_getAssociatedObject(self, (__bridge const void *)(kLabelShakingKey));
    if (shaking && [shaking boolValue]) {
        return;
    }
    
    objc_setAssociatedObject(self, (__bridge const void *)(kLabelShakingKey), @YES, OBJC_ASSOCIATION_ASSIGN);
    
    UIColor *originalColor = [self textColor];
    [self shake];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.1f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.layer addAnimation:transition forKey:nil];
    self.textColor = [UIColor colorWithRed:216/255.f green:80./255.f blue:80./255.f alpha:1.00];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CATransition *transition = [CATransition animation];
        transition.duration = 0.2f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        [self.layer addAnimation:transition forKey:nil];
        self.textColor = originalColor;
        
        objc_setAssociatedObject(self, (__bridge const void *)(kLabelShakingKey), nil, OBJC_ASSOCIATION_ASSIGN);
    });
}

@end
