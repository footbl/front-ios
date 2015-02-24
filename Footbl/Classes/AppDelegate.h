//
//  AppDelegate.h
//  Footbl
//
//  Created by Fernando Saragoça on 3/25/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FootblTabBarController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FootblTabBarController *footblTabBarController;

- (NSURL *)applicationDocumentsDirectory;

@end
