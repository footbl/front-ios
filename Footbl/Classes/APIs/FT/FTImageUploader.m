//
//  FTImageUploader.m
//  Footbl
//
//  Created by Fernando Saragoça on 8/11/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <Cloudinary/Cloudinary.h>

#import "FTImageUploader.h"

#pragma mark FTImageUploader

@implementation FTImageUploader

#pragma mark - Class Methods

+ (CLCloudinary *)cloudinary {
    static CLCloudinary *cloudinary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cloudinary = [CLCloudinary new];
#if FTB_ENVIRONMENT_PRODUCTION
		cloudinary.config[@"cloud_name"] = @"hivstsgwo";
		cloudinary.config[@"api_key"] = @"987722547954377";
		cloudinary.config[@"api_secret"] = @"JDxfvbY3BWwp3Nvnc-zQS6B-jog";
#else
		cloudinary.config[@"cloud_name"] = @"he5zfntay";
		cloudinary.config[@"api_key"] = @"854175976174894";
		cloudinary.config[@"api_secret"] = @"YFawEDfxmujOOGiTUKpAEU5O4eU";
#endif
    });
    return cloudinary;
}

+ (void)uploadImage:(UIImage *)image withSuccess:(FTBBlockObject)success failure:(FTBBlockError)failure {
    if (!image) {
        if (failure) {
            failure(nil);
        }
        return;
    }
	
	CLUploader *uploader = [[CLUploader alloc] init:[self cloudinary] delegate:nil];
    [uploader upload:UIImageJPEGRepresentation(image, 1.0) options:@{} withCompletion:^(NSDictionary *successResult, NSString *errorResult, NSInteger code, id context) {
        if (successResult && success) success(successResult[@"url"]);
        if (errorResult && failure) failure(nil);
    } andProgress:nil];
}

+ (void)uploadImage:(UIImage *)image withCompletion:(void (^)(NSString *imagePath, NSError *error))completion {
    [self uploadImage:image withSuccess:^(id response) {
		if (completion) completion(response, nil);
    } failure:^(NSError *error) {
		if (completion) completion(nil, error);
    }];
}

@end
