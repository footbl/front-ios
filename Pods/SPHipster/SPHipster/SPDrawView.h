//
//  SPDrawView.h
//  SPHipsterDemo
//
//  Created by Fernando Saragoça on 1/21/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPDrawView : UIView

- (void)setDrawRectBlock:(void (^)(CGRect rect))drawBlock;

@end
