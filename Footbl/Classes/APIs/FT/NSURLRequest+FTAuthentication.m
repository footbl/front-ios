//
//  NSURLRequest+FTAuthentication.m
//  Footbl
//
//  Created by Fernando Saragoça on 8/9/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "NSURLRequest+FTAuthentication.h"
#import "FTAuthenticationManager.h"
#import "NSString+Hex.h"
#import "NSString+SHA1.h"

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
    }
    
    if (!request.containsToken) {
        float unixTime = roundf((float)[[NSDate date] timeIntervalSince1970] * 1000.f);
        NSString *transactionIdentifier = [NSString randomHexStringWithLength:10];
        NSString *signature = [NSString stringWithFormat:@"%.00f%@%@", unixTime, transactionIdentifier, FTBSignatureKey.sha1];
        
        [request setValue:[NSString stringWithFormat:@"%.00f", unixTime] forHTTPHeaderField:@"auth-timestamp"];
        [request setValue:transactionIdentifier forHTTPHeaderField:@"auth-transactionId"];
        [request setValue:signature forHTTPHeaderField:@"auth-signature"];
		
        if ([FTAuthenticationManager sharedManager].isAuthenticated && [FTAuthenticationManager sharedManager].token.length > 0) {
            [request setValue:[FTAuthenticationManager sharedManager].token forHTTPHeaderField:@"auth-token"];
        }
    }
    
    return request;
}

@end
