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
+ (void)searchUsingEmails:(NSArray *)emails usernames:(NSArray *)usernames ids:(NSArray *)ids fbIds:(NSArray *)fbIds success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
+ (void)getMeWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
+ (void)getFeaturedWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
- (void)getStarredWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
- (void)getFansWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
- (void)starUser:(User *)user success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
- (void)unstarUser:(User *)user success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
- (BOOL)isStarredByUser:(User *)user;
- (NSDictionary *)dictionaryRepresentation;

@end
