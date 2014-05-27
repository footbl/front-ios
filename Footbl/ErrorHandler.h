//
//  ErrorHandler.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/27/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ErrorBlock)(NSError *error);

@interface ErrorHandler : NSObject

@property (assign, nonatomic, getter = isAlertVisible, readonly) BOOL alertVisible;;

+ (instancetype)sharedInstance;
+ (ErrorBlock)failureBlock;
- (void)displayError:(NSError *)error;
- (ErrorBlock)failureBlock;

@end
