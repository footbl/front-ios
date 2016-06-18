//
//  LoadingHelper.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/25/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

#import "LoadingHelper.h"

#pragma mark LoadingHelper

@implementation LoadingHelper

#pragma mark - Class Methods

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Instance Methods

- (id)init {
    self = [super init];
    if (self) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.animationType = MBProgressHUDAnimationZoom;
        [hud hide:NO];
    }
    return self;
}

- (MBProgressHUD *)showHud {
    MBProgressHUD *hud = [MBProgressHUD HUDForView:[[UIApplication sharedApplication] keyWindow]];
    if (!self.isVisible) {
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.animationType = MBProgressHUDAnimationZoom;
        [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
        _visible = YES;
    }
    return hud;
}

- (void)hideHud {
    MBProgressHUD *hud = [MBProgressHUD HUDForView:[[UIApplication sharedApplication] keyWindow]];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.animationType = MBProgressHUDAnimationZoom;
    [MBProgressHUD hideHUDForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    _visible = NO;
}

@end
