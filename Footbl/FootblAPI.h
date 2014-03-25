//
//  FootblAPI.h
//  Footbl
//
//  Created by Fernando Saragoça on 3/25/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface FootblAPI : AFHTTPRequestOperationManager

+ (instancetype)sharedAPI;
- (void)createAccountWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure;
- (void)loginWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure;
- (void)updateAccountWithUsername:(NSString *)username email:(NSString *)email password:(NSString *)password success:(void (^)())success failure:(void (^)(NSError *error))failure;

@end
