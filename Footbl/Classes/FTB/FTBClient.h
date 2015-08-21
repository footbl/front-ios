//
//  FTBClient.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/13/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "AFHTTPSessionManager.h"

typedef void (^FTBBlockArray)(NSArray *array);
typedef void (^FTBBlockObject)(id object);
typedef void (^FTBBlockError)(NSError *error);

@interface FTBClient : AFHTTPSessionManager

+ (void)championships:(NSUInteger)page success:(FTBBlockArray)success failure:(FTBBlockError)failure;
+ (void)championship:(NSString *)identifier success:(FTBBlockObject)success failure:(FTBBlockError)failure;

@end
