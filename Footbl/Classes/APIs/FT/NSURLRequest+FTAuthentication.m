//
//  NSURLRequest+FTAuthentication.m
//  Footbl
//
//  Created by Fernando Saragoça on 8/9/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "NSURLRequest+FTAuthentication.h"
#import "NSString+Hex.h"
#import "NSString+SHA1.h"
#import "FTBUser.h"

#pragma mark NSURLRequest (FTAuthentication)

@implementation NSURLRequest (FTAuthentication)

#pragma mark - Instance Methods

- (BOOL)containsToken {
	return [self allHTTPHeaderFields][@"Authorization"] != nil;
}

- (NSMutableURLRequest *)signedRequest {
    NSMutableURLRequest *request = (NSMutableURLRequest *)self;
    if (![self isKindOfClass:[NSMutableURLRequest class]]) {
        request = [self mutableCopy];
    }
    
    if (!request.containsToken) {
//        double unixTime = round([[NSDate date] timeIntervalSince1970] * 1000);
//        NSString *transactionIdentifier = [NSString randomHexStringWithLength:10];
//        NSString *signature = [NSString stringWithFormat:@"%.00f%@%@", unixTime, transactionIdentifier, FTBSignatureKey].sha1;
//        
//        [request setValue:[NSString stringWithFormat:@"%.00f", unixTime] forHTTPHeaderField:@"auth-timestamp"];
//        [request setValue:transactionIdentifier forHTTPHeaderField:@"auth-transactionId"];
//        [request setValue:signature forHTTPHeaderField:@"auth-signature"];
		
        if ([FTAuthenticationManager sharedManager].isAuthenticated) {
			FTBUser *user = [[FTAuthenticationManager sharedManager] user];
			NSString *authString = [NSString stringWithFormat:@"%@:%@", user.email, user.password];
			NSData *authData = [authString dataUsingEncoding:NSUTF8StringEncoding];
			NSString *auth = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:kNilOptions]];
			[request setValue:auth forHTTPHeaderField:@"Authorization"];
        }
    }
    
    return request;
}

@end
