//
//  TutorialViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/7/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TemplateViewController.h"

extern NSString * kPresentTutorialViewController;

@class StyledPageControl;

@interface TutorialViewController : TemplateViewController <UIScrollViewDelegate>

@property (copy, nonatomic) void (^completionBlock)();
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) StyledPageControl *pageControl;
@property (strong, nonatomic) UIButton *nextButton;
@property (strong, nonatomic) UIButton *getStartedButton;

+ (BOOL)shouldPresentTutorial;

@end
