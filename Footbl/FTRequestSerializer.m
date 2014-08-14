//
//  FTRequestSerializer.m
//  Footbl
//
//  Created by Fernando Saragoça on 8/7/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "FTOperationManager.h"
#import "FTRequestSerializer.h"
#import "NSString+Hex.h"
#import "NSString+SHA1.h"
#import "NSURLRequest+FTAuthentication.h"
#import "NSURLRequest+FTRequestOptions.h"

#pragma mark FTRequestSerializer

@implementation FTRequestSerializer

#pragma mark - Instance Methods

- (id)init {
    self = [super init];
    if (self) {
        _defaultOptions = FTRequestOptionAuthenticationRequired | FTRequestOptionAutoPage | FTRequestOptionGroupRequests;
        self.options = self.defaultOptions;
        
        [self setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    }
    return self;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters error:(NSError *__autoreleasing *)error {
    NSMutableURLRequest *request = [super requestWithMethod:method URLString:URLString parameters:parameters error:error];
    request.options = self.options;
    request.page = [parameters[@"page"] integerValue];
    return [request signedRequest];
}

@end
