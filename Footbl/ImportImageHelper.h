//
//  ImportImageHelper.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/15/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImportImageHelper : NSObject

+ (instancetype)sharedInstance;
- (void)importImageFromFacebookWithCompletionBlock:(void (^)(UIImage *image, NSError *error))completionBlock;

@end
