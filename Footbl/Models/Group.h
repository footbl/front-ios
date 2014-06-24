//
//  Group.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/04/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "_Group.h"

@class Championship;

@interface Group : _Group

+ (void)createWithChampionship:(Championship *)championship name:(NSString *)name image:(UIImage *)image members:(NSArray *)members invitedMembers:(NSArray *)invitedMembers success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
+ (void)joinGroupWithCode:(NSString *)code success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)updateMembersWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)addMembers:(NSArray *)members success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)addInvitedMembers:(NSArray *)members success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)saveWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)deleteWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (void)uploadImage:(UIImage *)image success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure;
- (NSString *)sharingText;

@end
