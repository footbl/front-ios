//
//  RechargeButton.h
//  Footbl
//
//  Created by Fernando Saragoca on 11/20/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RechargeButton : UIButton

@property (assign, nonatomic, getter=isAnimating) BOOL animating;
@property (assign, nonatomic) NSInteger numberOfAnimations;

@end
