//
//  FootblPopupAnimatedTransition.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/29/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <objc/runtime.h>
#import "FootblPopupAnimatedTransition.h"
#import "UIView+Frame.h"

#pragma mark FootblPopupAnimatedTransition

@implementation FootblPopupAnimatedTransition

static NSString * const kBlackViewAssociationKey = @"kBlackViewAssociationKey";

#pragma mark - Instance Methods

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.isPresenting) {
        [[transitionContext containerView] addSubview:fromViewController.view];
        
        UIView *blackView = [[UIView alloc] initWithFrame:fromViewController.view.frame];
        blackView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [[transitionContext containerView] addSubview:blackView];
        objc_setAssociatedObject(toViewController, (__bridge const void *)(kBlackViewAssociationKey), blackView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        CGRect finalFrame = CGRectMake(10, 26, fromViewController.view.frameWidth - 20, fromViewController.view.frameHeight - 58);
        
        toViewController.view.frame = CGRectMake(finalFrame.origin.x, [UIApplication sharedApplication].keyWindow.frameHeight + finalFrame.origin.y, finalFrame.size.width, finalFrame.size.height);
        toViewController.view.layer.cornerRadius = 3;
        toViewController.view.clipsToBounds = YES;
        [[transitionContext containerView] addSubview:toViewController.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
            blackView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
            toViewController.view.frame = finalFrame;
        } completion:^(BOOL finished) {
            toViewController.view.layer.shadowColor = [[UIColor blackColor] CGColor];
            toViewController.view.layer.shadowOpacity = 0.39;
            toViewController.view.layer.shadowOffset = CGSizeMake(0, 2);
            toViewController.view.layer.shadowRadius = 5;
            toViewController.view.clipsToBounds = NO;
            [transitionContext completeTransition:YES];
        }];
    } else {
        UIView *blackView = objc_getAssociatedObject(fromViewController, (__bridge const void *)(kBlackViewAssociationKey));
        [[transitionContext containerView] addSubview:toViewController.view];
        [[transitionContext containerView] addSubview:blackView];
        [[transitionContext containerView] addSubview:fromViewController.view];
        
        CGRect finalFrame = fromViewController.view.frame;
        finalFrame.origin.y = [UIApplication sharedApplication].keyWindow.frameHeight + finalFrame.origin.y;
        
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
