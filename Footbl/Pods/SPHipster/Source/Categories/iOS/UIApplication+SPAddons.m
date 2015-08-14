//
//  UIApplication+SPAddons.m
//  SPHipsterDemo
//
//  Created by Fernando Saragoça on 1/12/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "SPBuild.h"
#import "UIApplication+SPAddons.h"

#pragma mark UIApplication (SPAddons)

@implementation UIApplication (SPAddons)

#pragma mark - Instance Methods

- (SPBuildType)buildType {
    return SPGetBuildType();
}

- (NSString *)name {
    return SPGetApplicationName();
}

- (NSString *)version {
    return SPGetApplicationVersion();
}

@end
