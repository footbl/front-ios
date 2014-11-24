//
//  TransfersHelper.h
//  Footbl
//
//  Created by Fernando Saragoca on 11/24/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransfersHelper : NSObject

+ (void)fetchCountWithBlock:(void (^)(NSUInteger count))countBlock;

@end
