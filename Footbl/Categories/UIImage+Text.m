//
//  UIImage+Text.m
//  Footbl
//
//  Created by Leonardo Formaggio on 3/20/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import "UIImage+Text.h"
#import "UILabel+Image.h"
#import "FootblAppearance.h"

@implementation UIImage (Text)

+ (instancetype)imageWithText:(NSString *)text size:(CGSize)size {
    if (text.length == 0) {
        return nil;
    }
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.textAlignment = NSTextAlignmentCenter;
    label.minimumScaleFactor = 0.5;
    label.numberOfLines = 1;
    label.backgroundColor = [UIColor whiteColor];
    label.textColor = [UIColor ftb_greenGrassColor];
    label.font = [UIFont boldSystemFontOfSize:(size.height / 2)];
    label.text = text;
    return label.image;
}

@end
