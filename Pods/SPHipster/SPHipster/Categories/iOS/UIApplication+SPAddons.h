//
//  UIApplication+SPAddons.h
//  SPHipsterDemo
//
//  Created by Fernando Saragoça on 1/12/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPBuild.h"

@interface UIApplication (SPAddons)

- (SPBuildType)buildType;
- (NSString *)name;
- (NSString *)version;

@end
