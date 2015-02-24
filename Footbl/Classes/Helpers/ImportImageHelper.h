//
//  ImportImageHelper.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/15/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ImportImageHelperSource) {
    ImportImageHelperSourceCamera = 0,
    ImportImageHelperSourceLibrary = 1,
    ImportImageHelperSourceFacebook = 2
};

@interface ImportImageHelper : NSObject

+ (instancetype)sharedInstance;
- (void)importImageFromFacebookWithCompletionBlock:(void (^)(UIImage *image, NSError *error))completionBlock;
- (void)importFromGalleryWithCompletionBlock:(void (^)(UIImage *image, NSError *error))completionBlock;
- (void)importFromCameraWithCompletionBlock:(void (^)(UIImage *image, NSError *error))completionBlock;
- (void)importImageFromSources:(NSArray *)sources completionBlock:(void (^)(UIImage *image, NSError *error))completionBlock;

@end
