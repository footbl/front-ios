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

+ (void)createWithChampionship:(Championship *)championship name:(NSString *)name image:(UIImage *)image members:(NSArray *)members invitedMembers:(NSArray *)invitedMembers success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
+ (void)joinGroupWithCode:(NSString *)code success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
- (void)cancelMembersUpdate;
- (void)updateMembersWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
- (void)addMembers:(NSArray *)members success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
- (void)addInvitedMembers:(NSArray *)members success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
- (void)saveWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
- (void)deleteWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
- (void)uploadImage:(UIImage *)image success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;
- (NSString *)sharingText;
- (void)saveStatusInLocalDatabase;

@end
