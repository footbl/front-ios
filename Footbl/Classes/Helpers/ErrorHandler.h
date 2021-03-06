//
//  ErrorHandler.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/27/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ErrorBlock)(NSError *error);

@interface ErrorHandler : NSObject

@property (assign, nonatomic, getter = isAlertVisible, readonly) BOOL alertVisible;
@property (assign, nonatomic) BOOL shouldShowError;

+ (instancetype)sharedInstance;
+ (ErrorBlock)failureBlock;
- (void)displayError:(NSError *)error;
- (ErrorBlock)failureBlock;

@end
