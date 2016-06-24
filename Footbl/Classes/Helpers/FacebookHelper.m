//
//  FacebookHelper.m
//  Footbl
//
//  Created by Leonardo Formaggio on 6/23/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "FacebookHelper.h"

@implementation FacebookHelper

+ (void)performAuthenticatedAction:(void (^)(NSError *error))completion {
    if ([FBSDKAccessToken currentAccessToken]) {
        completion(nil);
    } else {
        UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (viewController.presentedViewController) {
            viewController = viewController.presentedViewController;
        }
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithReadPermissions:FB_READ_PERMISSIONS fromViewController:viewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            completion(error);
        }];
    }
}

@end
