//
//  SDImageCache+ShippedCache.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/3/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/SDWebImageManager.h>
#import <SPHipster/SPHipster.h>
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

- (void)downloadCachedImages {
    NSArray *urls = @[@"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/CAMEROON_yz5fne.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/BRAZIL_mwcpjv.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/BOSNIA_AND_H_i3q9dk.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/BELGIUM_wbozbs.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/AUSTRALIA_yq40sc.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/ARGENTINA_ig2aip.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/ALGERIA_xsommi.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/CROATIA_b0cy90.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/COTE_D_IVOIRE_qh5ulq.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/COSTA_RICA_otsbzc.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/COLOMBIA_vxscy2.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/CHILE_fb93aj.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/ECUADOR_iwr8ai.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/GREECE_eklvh6.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/GHANA_p0uaab.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/GERMANY_npdogu.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/FRANCE_rjkb8m.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/ENGLAND_vt1doa.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/HONDURAS_hs9d7v.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/IRAN_vtkpap.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/ITALY_jte7i0.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/JAPAN_lfy9os.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/KOREA_REPUBLIC_j48kp0.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/MEXICO_khba2g.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/NETHERLANDS_jwukjt.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/NIGERIA_blc8b2.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/PORTUGAL_cwaazf.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/RUSSIA_jq5ryr.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/SPAIN_lyclcq.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/SWITZERLAND_r9p9yv.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/URUGUAY_mrzf8s.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/USA_tsrfvq.png",
                      @"http://res.cloudinary.com/he5zfntay/image/upload/w_200,h_200,c_fit/WORLD_CUP_2_xdz6tm.png"];
    for (NSString *imageUrl in urls) {
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imageUrl] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (error) {
                SPLogError(@"Failed to download image: %@", imageUrl);
            }
        }];
    }
}

@end
