//
//  FTRequestSerializer.h
//  Footbl
//
//  Created by Fernando Saragoça on 8/7/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "AFURLRequestSerialization.h"

typedef NS_OPTIONS(NSUInteger, FTRequestOptions) {
    FTRequestOptionAuthenticationRequired = 1 << 0,
    FTRequestOptionAutoPage = 1 << 1,
    FTRequestOptionGroupRequests = 1 << 2
};

@interface FTRequestSerializer : AFHTTPRequestSerializer

@property (assign, nonatomic) FTRequestOptions options;
@property (assign, nonatomic, readonly) FTRequestOptions defaultOptions;

@end
