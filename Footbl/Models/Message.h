//
//  Message.h
//  Footbl
//
//  Created by Fernando Saragoça on 11/22/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "_Message.h"

@interface Message : _Message

+ (void)getWithGroup:(Group *)group page:(NSUInteger)page shouldDeleteUntouchedObjects:(BOOL)shouldDeleteUntouchedObjects success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
+ (void)markAsReadFromGroup:(Group *)group success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
+ (void)handleRemoteNotification:(NSDictionary *)notification;

@end
