//
//  FootblPopupAnimatedTransition.h
//  Footbl
//
//  Created by Fernando Saragoça on 7/29/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FootblPopupAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic, getter = isPresenting) BOOL presenting;

@end

@interface PopupTransitioningShow : NSObject <UIViewControllerAnimatedTransitioning>

@end

@interface PopupTransitioningHide : NSObject <UIViewControllerAnimatedTransitioning>

@end
