//
//  FootblAPI.h
//  Footbl
//
//  Created by Fernando Saragoça on 3/25/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

typedef void (^FootblAPISuccessBlock)();
typedef void (^FootblAPIFailureBlock)(NSError *error);

@interface FootblAPI : AFHTTPRequestOperationManager

+ (instancetype)sharedAPI;
- (void)createAccountWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)loginWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)updateAccountWithUsername:(NSString *)username email:(NSString *)email password:(NSString *)password success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;

@end
