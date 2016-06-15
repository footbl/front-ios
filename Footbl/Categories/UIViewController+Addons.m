//
//  UIViewController+Addons.m
//  Footbl
//
//  Created by Leonardo Formaggio on 6/15/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import "UIViewController+Addons.h"

@implementation UIViewController (Addons)

+ (NSString *)storyboardName {
    return nil;
}

+ (instancetype)instantiateFromStoryboard {
    NSString *storyboardName = [self storyboardName];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}

@end
