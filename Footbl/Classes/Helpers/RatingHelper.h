//
//  RatingHelper.h
//  Footbl
//
//  Created by Fernando Saragoça on 7/24/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RatingHelper : NSObject

+ (instancetype)sharedInstance;
- (void)run;
- (void)showAlert;

@end
