//
//  SDImageCache+ShippedCache.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/3/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "SDImageCache+ShippedCache.h"

#pragma mark SDImageCache (ShippedCache)

@implementation SDImageCache (ShippedCache)

#pragma mark - Instance Methods

- (void)importImagesFromPath:(NSString *)path error:(NSError **)error {
    @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSString *cachePath = [self performSelector:NSSelectorFromString(@"diskCachePath")];
#pragma clang diagnostic pop
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:error];
            if (error) return;
        }
        
        NSError *error = nil;
        NSArray *folderContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
        if (error) return;
        
        for (NSString *file in folderContents) {
            [[NSFileManager defaultManager] copyItemAtPath:[path stringByAppendingPathComponent:file] toPath:[cachePath stringByAppendingPathComponent:file] error:nil];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Failed to import images: %@", exception);
    }
}

@end
