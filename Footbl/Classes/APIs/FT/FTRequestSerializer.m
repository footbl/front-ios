//
//  FTRequestSerializer.m
//  Footbl
//
//  Created by Fernando Saragoça on 8/7/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "FTRequestSerializer.h"
#import "NSString+Hex.h"
#import "NSString+SHA1.h"
#import "NSURLRequest+FTAuthentication.h"
#import "NSURLRequest+FTRequestOptions.h"

#pragma mark FTRequestSerializer

@implementation FTRequestSerializer

#pragma mark - Instance Methods

- (NSURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters error:(NSError *__autoreleasing *)error {
    NSURLRequest *request = [super requestWithMethod:method URLString:URLString parameters:parameters error:error];
    return [request signedRequest];
}

@end
