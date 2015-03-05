//
//  FootblPopupAnimatedTransition.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/29/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <objc/runtime.h>
#import "FootblPopupAnimatedTransition.h"
#import "FootblPopupViewController.h"
#import "UIView+Frame.h"

#pragma mark FootblPopupAnimatedTransition

@implementation FootblPopupAnimatedTransition

static NSString * const kBlackViewAssociationKey = @"kBlackViewAssociationKey";

#pragma mark - Instance Methods

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    FootblPopupViewController *toViewController = (FootblPopupViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.isPresenting) {
        UIView *blackView = [[UIView alloc] initWithFrame:fromViewController.view.frame];
        blackView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [[transitionContext containerView] addSubview:blackView];
        objc_setAssociatedObject(toViewController, (__bridge const void *)(kBlackViewAssociationKey), blackView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        CGRect finalFrame = CGRectMake(10, 26, fromViewController.view.width - 20, fromViewController.view.height - 58);
        if ([toViewController respondsToSelector:@selector(frame)] && toViewController.frame.size.width > 0) {
            finalFrame = [(UIView *)toViewController frame];
        }
        
        toViewController.view.frame = CGRectMake(finalFrame.origin.x, [UIApplication sharedApplication].keyWindow.height + finalFrame.origin.y, finalFrame.size.width, finalFrame.size.height);
        toViewController.view.layer.cornerRadius = 3;
        toViewController.view.clipsToBounds = YES;
        [[transitionContext containerView] addSubview:toViewController.view];
        
        CGRect shadowPathRect = CGRectMake(-0.5, -0.5, finalFrame.size.width + 1, finalFrame.size.height + 1);
        toViewController.view.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:shadowPathRect cornerRadius:toViewController.view.layer.cornerRadius] CGPath];
        toViewController.view.layer.shadowColor = [[UIColor blackColor] CGColor];
        toViewController.view.layer.shadowOpacity = 0.39;
        toViewController.view.layer.shadowOffset = CGSizeMake(0, 2);
        toViewController.view.layer.shadowRadius = toViewController.view.layer.cornerRadius;
        toViewController.view.clipsToBounds = NO;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
            if ([toViewController respondsToSelector:@selector(backgroundColor)] && toViewController.backgroundColor) {
                blackView.backgroundColor = toViewController.backgroundColor;
            } else {
                blackView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
            }
            toViewController.view.frame = finalFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    } else {
        UIView *blackView = objc_getAssociatedObject(fromViewController, (__bridge const void *)(kBlackViewAssociationKey));
        [[transitionContext containerView] addSubview:blackView];
        [[transitionContext containerView] addSubview:fromViewController.view];
        
        CGRect finalFrame = fromViewController.view.frame;
        finalFrame.origin.y = [UIApplication sharedApplication].keyWindow.height + finalFrame.origin.y;
        
        fromViewController.view.layer.shadowColor = [[UIColor clearColor] CGColor];
        fromViewController.view.layer.shadowOpacity = 0;
        fromViewController.view.layer.shadowOffset = CGSizeZero;
        fromViewController.view.layer.shadowRadius = 0;
        fromViewController.view.clipsToBounds = YES;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] * 1.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            blackView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            fromViewController.view.frame = finalFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.4;
}

@end
