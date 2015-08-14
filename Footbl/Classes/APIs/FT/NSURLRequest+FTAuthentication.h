//
//  NSURLRequest+FTAuthentication.h
//  Footbl
//
//  Created by Fernando Saragoça on 8/9/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (FTAuthentication)

- (BOOL)containsToken;
- (NSMutableURLRequest *)signedRequest;

@end
