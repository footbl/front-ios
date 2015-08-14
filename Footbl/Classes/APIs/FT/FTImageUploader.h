//
//  FTImageUploader.h
//  Footbl
//
//  Created by Fernando Saragoça on 8/11/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FTOperationManager.h"

@class CLCloudinary;

@interface FTImageUploader : NSObject

+ (void)uploadImage:(UIImage *)image withSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
+ (void)uploadImage:(UIImage *)image withCompletion:(void (^)(NSString *imagePath, NSError *error))completion;
+ (CLCloudinary *)cloudinary;

@end
