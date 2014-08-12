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

+ (void)searchUsingEmails:(NSArray *)emails usernames:(NSArray *)usernames ids:(NSArray *)ids fbIds:(NSArray *)fbIds success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
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
    
    [[FTOperationManager sharedManager] performOperationWithOptions:FTRequestOptionAutoPage | FTRequestOptionGroupRequests operations:^{
       [[FTOperationManager sharedManager] GET:@"users" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
           if (success) success(responseObject);
       } failure:failure];
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

+ (void)getFeaturedWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[FTOperationManager sharedManager] GET:@"users" parameters:@{@"featured" : @YES} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self loadContent:responseObject inManagedObjectContext:[self editableManagedObjectContext] usingCache:nil enumeratingObjectsWithBlock:^(User *user, NSDictionary *data) {
            user.featured = @YES;
        } untouchedObjectsBlock:^(NSSet *untouchedObjects) {
            [untouchedObjects makeObjectsPerformSelector:@selector(setFeatured:) withObject:@NO];
        } completionBlock:success];
    } failure:failure];
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
    return [self.starredUsers filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"rid = %@", user.rid]].count > 0;
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

- (void)getStarredWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[FTOperationManager sharedManager] GET:[NSString stringWithFormat:@"users/%@/featured", self.rid] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[self class] loadContent:responseObject inManagedObjectContext:[[self class] editableManagedObjectContext] usingCache:nil enumeratingObjectsWithBlock:^(User *user, NSDictionary *data) {
            [self addStarredUsersObject:user];
        } untouchedObjectsBlock:^(NSSet *untouchedObjects) {
            [self removeStarredUsers:untouchedObjects];
        } completionBlock:success];
    } failure:failure];
}

- (void)getFansWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[FTOperationManager sharedManager] GET:[NSString stringWithFormat:@"users/%@/fans", self.rid] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[self class] loadContent:responseObject inManagedObjectContext:[[self class] editableManagedObjectContext] usingCache:nil enumeratingObjectsWithBlock:^(User *user, NSDictionary *data) {
            [self addFansObject:user];
        } untouchedObjectsBlock:^(NSSet *untouchedObjects) {
            [self removeFans:untouchedObjects];
        } completionBlock:success];
    } failure:failure];
}

- (void)starUser:(User *)user success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[[self class] editableManagedObjectContext] performBlock:^{
        [self addStarredUsersObject:user];
        user.followers = @(MAX(user.editableObject.followersValue + 1, MAX_FOLLOWERS_COUNT));
        [[[self class] editableManagedObjectContext] performSave];
    }];
    
    [[FTOperationManager sharedManager] POST:[NSString stringWithFormat:@"users/%@/featured", self.rid] parameters:@{@"featured" : user.rid} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) success(user);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[[self class] editableManagedObjectContext] performBlock:^{
            [self removeStarredUsersObject:user.editableObject];
            [[[self class] editableManagedObjectContext] performSave];
            if (failure) failure(operation, error);
        }];
    }];
}

- (void)unstarUser:(User *)user success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[[self class] editableManagedObjectContext] performBlock:^{
        [self removeStarredUsersObject:user.editableObject];
        if (user.followersValue < MAX_FOLLOWERS_COUNT) {
            user.followers = @(MAX(0, user.editableObject.followersValue - 1));
        }
        [[[self class] editableManagedObjectContext] performSave];
    }];
    
    [[FTOperationManager sharedManager] DELETE:[NSString stringWithFormat:@"users/%@/featured/%@", self.rid, user.rid] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) success(user);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[[self class] editableManagedObjectContext] performBlock:^{
            [self addStarredUsersObject:user.editableObject];
            [[[self class] editableManagedObjectContext] performSave];
            if (failure) failure(operation, error);
        }];
    }];
}

#pragma mark - Wallet

#warning FIX
- (NSNumber *)localFunds {
    return self.funds;
}

- (NSNumber *)localStake {
    return self.stake;
}

- (NSNumber *)toReturn {
    return @0;
}

- (NSString *)toReturnString {
    return @"";
}

- (NSNumber *)profit {
    return @0;
}

- (NSString *)profitString {
    return @"";
}

@end
