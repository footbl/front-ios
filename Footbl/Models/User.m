//
//  User.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/04/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <TransformerKit/TransformerKit.h>
#import "FootblAPI.h"
#import "User.h"
#import "Wallet.h"

@interface User ()

@end

#pragma mark User

@implementation User

#pragma mark - Class Methods

+ (NSString *)resourcePath {
    return @"users";
}

+ (instancetype)currentUser {
    return [self findOrCreateWithObject:@"me" inContext:[self editableManagedObjectContext]];
}

+ (void)searchUsingEmails:(NSArray *)emails usernames:(NSArray *)usernames ids:(NSArray *)ids fbIds:(NSArray *)fbIds success:(FootblAPISuccessWithResponseBlock)success failure:(FootblAPIFailureBlock)failure {
    NSString *key = [NSString stringWithFormat:@"%lu%lu%lu%lu%@", (unsigned long)emails.hash, (unsigned long)usernames.hash, (unsigned long)ids.hash, (unsigned long)fbIds.hash, API_DICTIONARY_KEY];
    NSMutableDictionary *parameters = [FootblModel generateParametersWithPage:API_CURRENT_PAGE(key)];
    if (emails) {
        parameters[@"emails"] = emails;
    }
    if (usernames) {
        parameters[@"usernames"] = usernames;
    }
    if (ids) {
        parameters[@"ids"] = ids;
    }
    if (fbIds) {
        parameters[@"facebookIds"] = fbIds;
    }
    
    [[FootblAPI sharedAPI] GET:@"users" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        API_APPEND_RESULT(responseObject, key);
        if ([responseObject count] == 20) {
            API_APPEND_PAGE(key);
            [self searchUsingEmails:emails usernames:usernames ids:ids fbIds:fbIds success:success failure:failure];
        } else {
            requestSucceedWithBlock(operation, parameters, nil);
            if (success) success(API_RESULT(key));
            API_RESET_KEY(key);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        requestFailedWithBlock(operation, parameters, error, failure);
        API_RESET_KEY(key);
    }];
}

+ (void)updateFeaturedUsersWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    NSString *key = API_DICTIONARY_KEY;
    NSMutableDictionary *parameters = [FootblModel generateParametersWithPage:API_CURRENT_PAGE(key)];
    parameters[@"featured"] = @YES;
    
    [[FootblAPI sharedAPI] GET:@"users" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        API_APPEND_RESULT(responseObject, key);
        if ([responseObject count] == 20) {
            API_APPEND_PAGE(key);
            [self updateFeaturedUsersWithSuccess:success failure:failure];
        } else {
            [FootblModel loadContent:API_RESULT(key) inManagedObjectContext:[self editableManagedObjectContext] usingCache:nil enumeratingObjectsWithBlock:^(User *user, NSDictionary *contentEntry) {
                user.featured = @YES;
            } deletingUntouchedObjectsWithBlock:^(NSSet *untouchedObjects) {
                [untouchedObjects makeObjectsPerformSelector:@selector(setFeatured:) withObject:@NO];
            }];
            
            requestSucceedWithBlock(operation, parameters, nil);
            if (success) success(API_RESULT(key));
            API_RESET_KEY(key);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        requestFailedWithBlock(operation, parameters, error, failure);
        API_RESET_KEY(key);
    }];
}

#pragma mark - Instance Methods

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
        
    if ([data[@"followers"] isKindOfClass:[NSNumber class]]) {
        self.followers = data[@"followers"];
    } else {
        self.followers = @0;
    }
    
    if (self.isMeValue) {
        self.slug = @"me";
        self.rid = @"me";
    }
}

- (BOOL)isStarredByUser:(User *)user {
    return [self.starredByUsers filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"rid = %@", user.rid]].count > 0;
}

- (void)updateStarredUsersWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    NSString *key = API_DICTIONARY_KEY;
    [[FootblAPI sharedAPI] groupOperationsWithKey:key block:^{
        [[FootblAPI sharedAPI] ensureAuthenticationWithSuccess:^{
            NSMutableDictionary *parameters = [FootblModel generateParametersWithPage:API_CURRENT_PAGE(key)];
            [[FootblAPI sharedAPI] GET:[NSString stringWithFormat:@"users/%@/starred", self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                API_APPEND_RESULT(responseObject, key);
                if ([responseObject count] == 20) {
                    API_APPEND_PAGE(key);
                    [FootblAPI performOperationWithoutGrouping:^{
                        [self updateStarredUsersWithSuccess:success failure:failure];
                    }];
                } else {
                    [[self class] loadContent:API_RESULT(key) inManagedObjectContext:self.managedObjectContext usingCache:nil enumeratingObjectsWithBlock:^(User *user, NSDictionary *contentEntry) {
                        if (![self.starredUsers containsObject:user]) {
                            [self addStarredUsersObject:user];
                        }
                    } deletingUntouchedObjectsWithBlock:^(NSSet *untouchedObjects) {
                        [self removeStarredUsers:untouchedObjects];
                    }];
                    requestSucceedWithBlock(operation, parameters, nil);
                    [[FootblAPI sharedAPI] finishGroupedOperationsWithKey:key error:nil];
                    API_RESET_KEY(key);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                requestFailedWithBlock(operation, parameters, error, nil);
                [[FootblAPI sharedAPI] finishGroupedOperationsWithKey:key error:error];
                API_RESET_KEY(key);
            }];
        } failure:^(NSError *error) {
            [[FootblAPI sharedAPI] finishGroupedOperationsWithKey:key error:error];
        }];
    } success:success failure:failure];
}

- (void)unstarUser:(User *)user success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[[self class] editableManagedObjectContext] performBlock:^{
        [self removeStarredUsersObject:user.editableObject];
        user.editableObject.followers = @(MAX(0, user.editableObject.followersValue - 1));
        [[[self class] editableManagedObjectContext] performSave];
    }];
    
    [[FootblAPI sharedAPI] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [FootblModel generateDefaultParameters];
        parameters[@"user"] = user.rid;
        [[FootblAPI sharedAPI] DELETE:[NSString stringWithFormat:@"users/%@/starred/%@", self.rid, user.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            requestSucceedWithBlock(operation, parameters, success);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[[self class] editableManagedObjectContext] performBlock:^{
                [self addStarredUsersObject:user.editableObject];
                [[[self class] editableManagedObjectContext] performSave];
                requestFailedWithBlock(operation, parameters, error, failure);
            }];
        }];
    } failure:failure];
}

- (void)starUser:(User *)user success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[[self class] editableManagedObjectContext] performBlock:^{
        [self addStarredUsersObject:user.editableObject];
        user.editableObject.followers = @(user.editableObject.followersValue + 1);
        [[[self class] editableManagedObjectContext] performSave];
    }];
    
    [[FootblAPI sharedAPI] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [FootblModel generateDefaultParameters];
        parameters[@"user"] = user.rid;
        [[FootblAPI sharedAPI] POST:[NSString stringWithFormat:@"users/%@/starred", self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            requestSucceedWithBlock(operation, parameters, success);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[[self class] editableManagedObjectContext] performBlock:^{
                [self removeStarredUsersObject:user.editableObject];
                [[[self class] editableManagedObjectContext] performSave];
                requestFailedWithBlock(operation, parameters, error, failure);
            }];
        }];
    } failure:failure];
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    if (self.email) {
        dictionary[@"email"] = self.email;
    }
    if (self.username) {
        dictionary[@"username"] = self.username;
    }
    if (self.name) {
        dictionary[@"name"] = self.name;
    }
    if (self.picture) {
        dictionary[@"picture"] = self.picture;
    }
    if (self.about) {
        dictionary[@"about"] = self.about;
    }
    return dictionary;
}

- (void)deleteWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    NSMutableDictionary *parameters = [FootblModel generateDefaultParameters];
    [[FootblAPI sharedAPI] DELETE:[NSString stringWithFormat:@"users/%@", self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[FootblAPI sharedAPI] logout];
        requestSucceedWithBlock(operation, parameters, success);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        requestFailedWithBlock(operation, parameters, error, failure);
    }];
}

+ (void)getMeWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[FTOperationManager sharedManager] GET:@"users/me" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
       [[self editableManagedObjectContext] performBlock:^{
           User *user = [User findOrCreateWithObject:responseObject inContext:[self editableManagedObjectContext]];
           user.isMeValue = YES;
           [[self editableManagedObjectContext] performSave];
           if (success) success(user);
       }];
    } failure:failure];
}

@end
