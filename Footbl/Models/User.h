//
//  User.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/04/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "_User.h"

@interface User : _User

+ (instancetype)currentUser;
+ (void)searchUsingEmails:(NSArray *)emails usernames:(NSArray *)usernames ids:(NSArray *)ids fbIds:(NSArray *)fbIds success:(FootblAPISuccessWithResponseBlock)success failure:(FootblAPIFailureBlock)failure;
- (NSDictionary *)dictionaryRepresentation;
- (BOOL)isMe;

@end
