//
//  Championship.h
//  Footbl
//
//  Created by Fernando Saragoça on 3/26/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "_Championship.h"

@interface Championship : _Championship

+ (void)updateWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)updateWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;

@end
