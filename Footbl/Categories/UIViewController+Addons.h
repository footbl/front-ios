//
//  UIViewController+Addons.h
//  Footbl
//
//  Created by Leonardo Formaggio on 6/15/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Addons)

+ (NSString *)storyboardName;
+ (instancetype)instantiateFromStoryboard;

@end
