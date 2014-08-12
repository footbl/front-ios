//
//  FTImageUploader.h
//  Footbl
//
//  Created by Fernando Saragoça on 8/11/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FTOperationManager.h"

@class CLCloudinary;

@interface FTImageUploader : NSObject

+ (void)uploadImage:(UIImage *)image withSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
+ (CLCloudinary *)cloudinary;

@end
