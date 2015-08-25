//
//  SDImageCache+ShippedCache.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/3/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "SDImageCache.h"

@interface SDImageCache (ShippedCache)

- (BOOL)importImagesFromPath:(NSString *)path error:(NSError **)error;
- (void)downloadCachedImages;

@end
