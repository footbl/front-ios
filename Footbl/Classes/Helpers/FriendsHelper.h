//
//  FriendsHelper.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/13/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendsHelper : NSObject

+ (instancetype)sharedInstance;
- (void)getFriendsWithCompletionBlock:(void (^)(NSArray *friends, NSError *error))completionBlock;
- (void)getFbFriendsWithCompletionBlock:(void (^)(NSArray *friends, NSError *error))completionBlock;
- (void)getFbInvitableFriendsWithCompletionBlock:(void (^)(NSArray *friends, NSError *error))completionBlock;
- (void)reloadFriendsWithCompletionBlock:(void (^)(NSArray *friends, NSError *error))completionBlock;
- (void)searchFriendsWithQuery:(NSString *)searchText completionBlock:(void (^)(NSArray *friends, NSError *error))completionBlock;
- (void)searchFriendsWithQuery:(NSString *)searchText existingUsers:(NSSet *)users completionBlock:(void (^)(NSArray *friends, NSError *error))completionBlock;

@end
