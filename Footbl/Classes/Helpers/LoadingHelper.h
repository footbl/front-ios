//
//  LoadingHelper.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/25/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBProgressHUD;

@interface LoadingHelper : NSObject

@property (assign, nonatomic, readonly, getter = isVisible) BOOL visible;

+ (instancetype)sharedInstance;
- (MBProgressHUD *)showHud;
- (void)hideHud;

@end
