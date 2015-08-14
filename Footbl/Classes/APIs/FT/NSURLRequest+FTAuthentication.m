//
//  NSURLRequest+FTAuthentication.m
//  Footbl
//
//  Created by Fernando Saragoça on 8/9/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "FTAuthenticationManager.h"
#import "FTOperationManager.h"
#import "NSString+Hex.h"
#import "NSString+SHA1.h"
#import "NSURLRequest+FTAuthentication.h"
#import "NSURLRequest+FTRequestOptions.h"

#pragma mark NSURLRequest (FTAuthentication)

@implementation NSURLRequest (FTAuthentication)

#pragma mark - Instance Methods

- (BOOL)containsToken {
    return [self allHTTPHeaderFields][@"auth-token"] ? YES : NO;
}

- (NSMutableURLRequest *)signedRequest {
    NSMutableURLRequest *request = (NSMutableURLRequest *)self;
    if (![self isKindOfClass:[NSMutableURLRequest class]]) {
        request = [self mutableCopy];
        request.options = self.options;
        request.page = self.page;
    }
    
    if (![request.URL.host isEqualToString:[FTOperationManager sharedManager].baseURL.host]) {
        NSString *newURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:request.URL.host withString:[FTOperationManager sharedManager].baseURL.host];
        request.URL = [NSURL URLWithString:newURL];
    }
    
    if (!request.containsToken) {
        float unixTime = roundf((float)[[NSDate date] timeIntervalSince1970] * 1000.f);
        NSString *transactionIdentifier = [NSString randomHexStringWithLength:10];
        NSString *signature = [NSString stringWithFormat:@"%.00f%@%@", unixTime, transactionIdentifier, [FTOperationManager sharedManager].signatureKey].sha1;
        
        [request setValue:[NSString stringWithFormat:@"%.00f", unixTime] forHTTPHeaderField:@"auth-timestamp"];
        [request setValue:transactionIdentifier forHTTPHeaderField:@"auth-transactionId"];
        [request setValue:signature forHTTPHeaderField:@"auth-signature"];
        
        BOOL authenticationRequired = (request.options & FTRequestOptionAuthenticationRequired);
        if (authenticationRequired && [FTAuthenticationManager sharedManager].isAuthenticated && [FTAuthenticationManager sharedManager].token.length > 0) {
            [request setValue:[FTAuthenticationManager sharedManager].token forHTTPHeaderField:@"auth-token"];
        }
    }
    
    return request;
}

@end
