//
//  TemplateViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "SPTemplateViewController.h"

@interface TemplateViewController : SPTemplateViewController

- (void)reloadData NS_REQUIRES_SUPER;
- (NSTimeInterval)updateInterval;

@end
