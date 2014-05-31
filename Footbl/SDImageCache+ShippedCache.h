//
//  SDImageCache+ShippedCache.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/3/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "SDImageCache.h"

@interface SDImageCache (ShippedCache)

- (void)importImagesFromPath:(NSString *)path error:(NSError **)error;
- (void)downloadCachedImages;

@end
