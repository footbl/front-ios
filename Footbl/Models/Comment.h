//
//  Comment.h
//  Footbl
//
//  Created by Fernando Saragoça on 3/26/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "_Comment.h"

@interface Comment : _Comment

+ (void)createCommentInMatch:(Match *)match withMessage:(NSString *)message success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
+ (void)updateFromMatch:(Match *)match success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;

@end
