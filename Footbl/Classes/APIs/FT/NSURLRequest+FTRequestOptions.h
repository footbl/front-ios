//
//  NSURLRequest+FTRequestOptions.h
//  Footbl
//
//  Created by Fernando Saragoça on 8/9/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FTRequestSerializer.h"

@interface NSURLRequest (FTRequestOptions)

@property (assign, nonatomic) FTRequestOptions options;
@property (assign, nonatomic) NSInteger page;

@end
