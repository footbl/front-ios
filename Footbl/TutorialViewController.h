//
//  TutorialViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/7/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TemplateViewController.h"

extern NSString * kPresentTutorialViewController;

@interface TutorialViewController : TemplateViewController

@property (copy, nonatomic) void (^completionBlock)();

+ (BOOL)shouldPresentTutorial;

@end
