//
//  ImportImageHelper.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/15/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <SDWebImage/SDWebImageManager.h>
#import "ImportImageHelper.h"

#pragma mark ImportImageHelper

@implementation ImportImageHelper

#pragma mark - Class Methods

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

#pragma mark - Instance Methods

- (void)importImageFromFacebookWithCompletionBlock:(void (^)(UIImage *image, NSError *error))completionBlock {
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            if (completionBlock) completionBlock(nil, error);
            return;
        }
        
        NSString *picturePath = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", result[@"id"]];
        [SDWebImageManager.sharedManager downloadWithURL:[NSURL URLWithString:picturePath] options:SDWebImageCacheMemoryOnly | SDWebImageHighPriority progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
            if (error) {
                if (completionBlock) completionBlock(nil, error);
                return;
            }
            if (completionBlock) completionBlock(image, nil);
        }];
    }];
}

@end
