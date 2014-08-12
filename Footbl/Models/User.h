//
//  User.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/04/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "_User.h"
#import "FootblAPI.h"

@interface User : _User

+ (instancetype)currentUser;
+ (void)searchUsingEmails:(NSArray *)emails usernames:(NSArray *)usernames ids:(NSArray *)ids fbIds:(NSArray *)fbIds success:(FootblAPISuccessWithResponseBlock)success failure:(FootblAPIFailureBlock)failure;
+ (void)updateFeaturedUsersWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (NSDictionary *)dictionaryRepresentation;
- (void)starUser:(User *)user success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)unstarUser:(User *)user success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (BOOL)isStarredByUser:(User *)user;
- (void)updateStarredUsersWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)deleteWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
+ (void)getMeWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;

@end
