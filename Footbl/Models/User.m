//
//  User.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/04/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <TransformerKit/TransformerKit.h>
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
    return [[self API] currentUser];
}

+ (void)searchUsingEmails:(NSArray *)emails usernames:(NSArray *)usernames ids:(NSArray *)ids fbIds:(NSArray *)fbIds success:(FootblAPISuccessWithResponseBlock)success failure:(FootblAPIFailureBlock)failure {
    NSString *key = [NSString stringWithFormat:@"%lu%lu%lu%lu%@", (unsigned long)emails.hash, (unsigned long)usernames.hash, (unsigned long)ids.hash, (unsigned long)fbIds.hash, API_DICTIONARY_KEY];
    NSMutableDictionary *parameters = [self generateParametersWithPage:API_CURRENT_PAGE(key)];
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
    
    [[self API] GET:@"users" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        API_APPEND_RESULT(responseObject, key);
        if ([responseObject count] == [self responseLimit]) {
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

#pragma mark - Instance Methods

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    self.verified = data[@"verified"];
    self.email = data[@"email"];
    self.username = data[@"username"];
    self.name = data[@"name"];
    self.about = data[@"about"];
    self.picture = data[@"picture"];
    NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName];
    self.createdAt = [transformer reverseTransformedValue:data[@"createdAt"]];
    
    if ([data[@"followers"] isKindOfClass:[NSNumber class]]) {
        self.followers = data[@"followers"];
    } else {
        self.followers = @0;
    }
}

- (BOOL)isMe {
    return [User currentUser] && [[User currentUser].rid isEqualToString:self.rid];
}

- (BOOL)isStarredByUser:(User *)user {
    return [self.starredByUsers filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"rid = %@", user.rid]].count > 0;
}

- (void)updateStarredUsersWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    NSString *key = API_DICTIONARY_KEY;
    [[self API] groupOperationsWithKey:key block:^{
        [[self API] ensureAuthenticationWithSuccess:^{
            NSMutableDictionary *parameters = [self generateParametersWithPage:API_CURRENT_PAGE(key)];
            [[self API] GET:[NSString stringWithFormat:@"users/%@/starred", self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                API_APPEND_RESULT(responseObject, key);
                if ([responseObject count] == [self responseLimit]) {
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
                    [[self API] finishGroupedOperationsWithKey:key error:nil];
                    API_RESET_KEY(key);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                requestFailedWithBlock(operation, parameters, error, nil);
                [[self API] finishGroupedOperationsWithKey:key error:error];
                API_RESET_KEY(key);
            }];
        } failure:^(NSError *error) {
            [[self API] finishGroupedOperationsWithKey:key error:error];
        }];
    } success:success failure:failure];
}

- (void)unstarUser:(User *)user success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [self.editableManagedObjectContext performBlock:^{
        [self removeStarredUsersObject:user.editableObject];
        user.editableObject.followers = @(MAX(0, user.editableObject.followersValue - 1));
        SaveManagedObjectContext(self.editableManagedObjectContext);
    }];
    
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        parameters[@"user"] = user.rid;
        [[self API] DELETE:[NSString stringWithFormat:@"users/%@/starred/%@", self.rid, user.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            requestSucceedWithBlock(operation, parameters, success);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self.editableManagedObjectContext performBlock:^{
                [self addStarredUsersObject:user.editableObject];
                SaveManagedObjectContext(self.editableManagedObjectContext);
                requestFailedWithBlock(operation, parameters, error, failure);
            }];
        }];
    } failure:failure];
}

- (void)starUser:(User *)user success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [self.editableManagedObjectContext performBlock:^{
        [self addStarredUsersObject:user.editableObject];
        user.editableObject.followers = @(user.editableObject.followersValue + 1);
        SaveManagedObjectContext(self.editableManagedObjectContext);
    }];
    
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        parameters[@"user"] = user.rid;
        [[self API] POST:[NSString stringWithFormat:@"users/%@/starred", self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            requestSucceedWithBlock(operation, parameters, success);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self.editableManagedObjectContext performBlock:^{
                [self removeStarredUsersObject:user.editableObject];
                SaveManagedObjectContext(self.editableManagedObjectContext);
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
    NSMutableDictionary *parameters = [self generateDefaultParameters];
    [[self API] DELETE:[NSString stringWithFormat:@"users/%@", self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[FootblAPI sharedAPI] logout];
        requestSucceedWithBlock(operation, parameters, success);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        requestFailedWithBlock(operation, parameters, error, failure);
    }];
}

@end
