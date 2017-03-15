//
//  RatingHelper.h
//  Footbl
//
//  Created by Fernando Saragoça on 7/24/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSInteger const WalletReference;

@interface RatingHelper : NSObject

+ (instancetype)sharedInstance;
- (void)run;
- (void)showAlert;

@end
