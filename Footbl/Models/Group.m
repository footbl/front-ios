//
//  Group.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/04/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "Championship.h"
#import "Group.h"
#import "Membership.h"
#import "User.h"

@interface Group ()

@end

#pragma mark Group

@implementation Group

#pragma mark - Class Methods

+ (NSString *)resourcePath {
    return @"groups";
}

+ (void)createWithChampionship:(Championship *)championship name:(NSString *)name image:(UIImage *)image members:(NSArray *)members invitedMembers:(NSArray *)invitedMembers success:(FootblAPISuccessWithResponseBlock)success failure:(FootblAPIFailureBlock)failure {
    void(^requestBlock)(NSString *picturePath) = ^(NSString *picturePath) {
        [[self API] ensureAuthenticationWithSuccess:^{
            NSMutableDictionary *parameters = [self generateDefaultParameters];
            parameters[@"name"] = name;
            parameters[@"championship"] = championship.rid;
            if (picturePath) {
                parameters[@"picture"] = picturePath;
            }
            [[self API] POST:@"groups" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self.editableManagedObjectContext performBlock:^{
                    Group *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.editableManagedObjectContext];
                    group.rid = responseObject[kAPIIdentifierKey];
                    [group updateWithData:responseObject];
                    requestSucceedWithBlock(operation, parameters, nil);
                    SaveManagedObjectContext(self.editableManagedObjectContext);
                    __weak typeof(Group *)weakGroup = group;
                    [group addMembers:members success:^{
                        [weakGroup addInvitedMembers:invitedMembers success:^{
                            [weakGroup updateMembersWithSuccess:^(id response) {
                                if (success) success(weakGroup);
                            } failure:^(NSError *error) {
                                if (success) success(weakGroup);
                            }];
                        } failure:failure];
                    } failure:failure];
                }];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                requestFailedWithBlock(operation, parameters, error, failure);
            }];
        } failure:failure];
    };
    
    if (image) {
        [[self API] uploadImage:image withCompletionBlock:^(NSString *response, NSError *error) {
            requestBlock(response);
        }];
    } else {
        requestBlock(championship.picture);
    }
}

+ (void)updateWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    NSString *key = API_DICTIONARY_KEY;
    [[self API] groupOperationsWithKey:key block:^{
        [[self API] ensureAuthenticationWithSuccess:^{
            NSMutableDictionary *parameters = [self generateParametersWithPage:API_CURRENT_PAGE(key)];
            [[self API] GET:[[self class] resourcePath] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                API_APPEND_RESULT(responseObject, key);
                if ([[operation responseObject] count] == [self responseLimit]) {
                    API_APPEND_PAGE(key);
                    [FootblAPI performOperationWithoutGrouping:^{
                        [self updateWithSuccess:success failure:failure];
                    }];
                } else {
                    [self loadContent:API_RESULT(key) inManagedObjectContext:self.editableManagedObjectContext usingCache:nil enumeratingObjectsWithBlock:nil deletingUntouchedObjectsWithBlock:^(NSSet *untouchedObjects) {
                        [untouchedObjects enumerateObjectsUsingBlock:^(Group *group, BOOL *stop) {
                            if (!group.isDefaultValue) {
                                [[self editableManagedObjectContext] deleteObject:group];
                            }
                        }];
                    }];
                    requestSucceedWithBlock(operation, parameters, success);
                    [[self API] finishGroupedOperationsWithKey:key error:nil];
                    API_RESET_KEY(key);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                requestFailedWithBlock(operation, parameters, error, failure);
                [[self API] finishGroupedOperationsWithKey:key error:error];
                API_RESET_KEY(key);
            }];
        } failure:^(NSError *error) {
            [[self API] finishGroupedOperationsWithKey:key error:error];
            if (failure) failure(error);
        }];
    } success:success failure:failure];
}

+ (void)joinGroupWithCode:(NSString *)code success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        parameters[@"code"] = code;
        [[self API] GET:@"groups" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            requestSucceedWithBlock(operation, parameters, nil);
            NSDictionary *groupDictionary = [responseObject firstObject];
            if ([Group findByIdentifier:groupDictionary[kAPIIdentifierKey] inManagedObjectContext:[self editableManagedObjectContext]]) {
                if (success) success();
            } else if (groupDictionary) {
                NSMutableDictionary *joinGroupParameters = [self generateDefaultParameters];
                joinGroupParameters[@"user"] = [User currentUser].rid;
                joinGroupParameters[@"code"] = code;
                [[self API] POST:[NSString stringWithFormat:@"groups/%@/members", groupDictionary[kAPIIdentifierKey]] parameters:joinGroupParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [[self editableManagedObjectContext] performBlock:^{
                        Group *group = [Group findOrCreateByIdentifier:groupDictionary[kAPIIdentifierKey] inManagedObjectContext:[self editableManagedObjectContext]];
                        [group updateWithData:groupDictionary];
                        SaveManagedObjectContext([self editableManagedObjectContext]);
                        requestSucceedWithBlock(operation, joinGroupParameters, nil);
                        [group updateMembersWithSuccess:success failure:^(NSError *error) {
                            if (success) success();
                        }];
                    }];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    requestFailedWithBlock(operation, joinGroupParameters, error, failure);
                }];
            } else {
                if (failure) failure([NSError errorWithDomain:FootblAPIErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"Error: group not found", @"")}]);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

#pragma mark - Instance Methods

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    self.name = data[@"name"];
    self.picture = data[@"picture"];
    self.freeToEdit = data[@"freeToEdit"];
    self.code = data[@"code"];
    self.owner = [User findOrCreateByIdentifier:data[@"owner"] inManagedObjectContext:self.managedObjectContext];
    if ([data[@"owner"] isKindOfClass:[NSDictionary class]]) {
        [self.owner updateWithData:data[@"owner"]];
    }
    
    NSString *championship = data[@"championship"];
    if ([championship isKindOfClass:[NSDictionary class]]) {
        self.championship = [Championship findOrCreateByIdentifier:data[@"championship"][kAPIIdentifierKey] inManagedObjectContext:self.managedObjectContext];
        [self.championship updateWithData:data[@"championship"]];
    } else {
        self.championship = [Championship findByIdentifier:championship inManagedObjectContext:self.managedObjectContext];
    }
}

- (void)addMembers:(NSArray *)members success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    if (members.count == 0) {
        if (success) success();
        return;
    }
    
    [[self API] ensureAuthenticationWithSuccess:^{
        __block NSMutableArray *pendingMembers = [members mutableCopy];
        __block NSError *operationError = nil;
        [members enumerateObjectsUsingBlock:^(NSDictionary *user, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *parameters = [self generateDefaultParameters];
            parameters[@"user"] = user[kAPIIdentifierKey];
            [[self API] POST:[NSString stringWithFormat:@"groups/%@/members", self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [pendingMembers removeObject:user];
                if (pendingMembers.count == 0) {
                    if (operationError) {
                        requestFailedWithBlock(operation, parameters, operationError, failure);
                    } else {
                        requestSucceedWithBlock(operation, parameters, success);
                    }
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                operationError = error;
                [pendingMembers removeObject:user];
                if (pendingMembers.count == 0) {
                    requestFailedWithBlock(operation, parameters, error, failure);
                }
            }];
        }];
    } failure:failure];
}

- (void)addInvitedMembers:(NSArray *)members success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    if (members.count == 0) {
        if (success) success();
        return;
    }
    
    [[self API] ensureAuthenticationWithSuccess:^{
        __block NSMutableArray *pendingMembers = [members mutableCopy];
        __block NSError *operationError = nil;
        [members enumerateObjectsUsingBlock:^(NSDictionary *user, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *parameters = [self generateDefaultParameters];
            if ([user isKindOfClass:[NSDictionary class]]) {
                parameters[@"facebookId"] = user[@"id"];
            } else {
                parameters[@"email"] = user;
            }
            [[self API] POST:[NSString stringWithFormat:@"groups/%@/invites", self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [pendingMembers removeObject:user];
                if (pendingMembers.count == 0) {
                    if (operationError) {
                        requestFailedWithBlock(operation, parameters, operationError, failure);
                    } else {
                        requestSucceedWithBlock(operation, parameters, success);
                    }
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (operation.response.statusCode >= 200 && operation.response.statusCode < 300) {
                    [pendingMembers removeObject:user];
                    if (pendingMembers.count == 0) {
                        if (operationError) {
                            requestFailedWithBlock(operation, parameters, operationError, failure);
                        } else {
                            requestSucceedWithBlock(operation, parameters, success);
                        }
                    }
                } else {
                    operationError = error;
                    [pendingMembers removeObject:user];
                    if (pendingMembers.count == 0) {
                        requestFailedWithBlock(operation, parameters, error, failure);
                    }
                }
            }];
        }];
    } failure:failure];
}

- (void)cancelMembersUpdate {
    NSString *key = [NSString stringWithFormat:@"%@updateMembersWithSuccess:", self.rid];
    API_RESET_KEY(key);
}

- (void)updateMembersWithSuccess:(FootblAPISuccessWithResponseBlock)success failure:(FootblAPIFailureBlock)failure {
    NSString *key = [NSString stringWithFormat:@"%@updateMembersWithSuccess:", self.rid];
    if (self.isDefaultValue) {
        [[self API] ensureAuthenticationWithSuccess:^{
            NSMutableDictionary *parameters = [self generateParametersWithPage:API_CURRENT_PAGE(key)];
            [[self API] GET:[NSString stringWithFormat:@"championships/%@/ranking", self.championship.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                API_APPEND_RESULT(responseObject, key);
                [Membership loadContent:API_RESULT(key) inManagedObjectContext:self.managedObjectContext usingCache:self.members enumeratingObjectsWithBlock:^(Membership *membership, NSDictionary *contentEntry) {
                    membership.group = self;
                } deletingUntouchedObjectsWithBlock:^(NSSet *untouchedObjects) {
                    [self.managedObjectContext deleteObjects:untouchedObjects];
                }];
                
                if ([[operation responseObject] count] == [self responseLimit]) {
                    API_APPEND_PAGE(key);
                    if (success) success(@YES);
                } else {
                    requestSucceedWithBlock(operation, parameters, nil);
                    if (success) success(@NO);
                    API_RESET_KEY(key);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                requestFailedWithBlock(operation, parameters, error, failure);
                API_RESET_KEY(key);
            }];
        } failure:^(NSError *error) {
            API_RESET_KEY(key);
        }];
    } else {
        [[self API] ensureAuthenticationWithSuccess:^{
            NSMutableDictionary *parameters = [self generateParametersWithPage:API_CURRENT_PAGE(key)];
            [[self API] GET:[NSString stringWithFormat:@"groups/%@/members", self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                API_APPEND_RESULT(responseObject, key);
                if ([[operation responseObject] count] == [self responseLimit]) {
                    API_APPEND_PAGE(key);
                    [FootblAPI performOperationWithoutGrouping:^{
                        [self updateMembersWithSuccess:success failure:failure];
                    }];
                } else {
                    [Membership loadContent:API_RESULT(key) inManagedObjectContext:self.managedObjectContext usingCache:self.members enumeratingObjectsWithBlock:^(Membership *membership, NSDictionary *contentEntry) {
                        membership.group = self;
                    } deletingUntouchedObjectsWithBlock:^(NSSet *untouchedObjects) {
                        [self.managedObjectContext deleteObjects:untouchedObjects];
                    }];
                    requestSucceedWithBlock(operation, parameters, nil);
                    if (success) success(@NO);
                    API_RESET_KEY(key);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                requestFailedWithBlock(operation, parameters, error, failure);
                API_RESET_KEY(key);
            }];
        } failure:^(NSError *error) {
            API_RESET_KEY(key);
        }];
    }
}

- (void)saveWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSString *oldName = self.name.copy;
        NSNumber *oldFreeToEdit = self.freeToEdit.copy;
        
        [self.editableManagedObjectContext performBlock:^{
            SaveManagedObjectContext(self.editableManagedObjectContext);
        }];
        
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        parameters[@"name"] = self.name;
        parameters[@"freeToEdit"] = self.freeToEdit;
        if (self.picture) {
            parameters[@"picture"] = self.picture;
        }
        [[self API] PUT:[NSString stringWithFormat:@"groups/%@", self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.editableManagedObjectContext performBlock:^{
                [self updateWithData:responseObject];
                SaveManagedObjectContext(self.editableManagedObjectContext);
                requestSucceedWithBlock(operation, parameters, success);
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self.editableManagedObjectContext performBlock:^{
                self.name = oldName;
                self.freeToEdit = oldFreeToEdit;
            }];
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

- (void)uploadImage:(UIImage *)image success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    void(^requestBlock)(NSString *picturePath) = ^(NSString *picturePath) {
        [[self API] ensureAuthenticationWithSuccess:^{
            self.picture = picturePath;
            
            [self.editableManagedObjectContext performBlock:^{
                SaveManagedObjectContext(self.editableManagedObjectContext);
            }];
            
            NSMutableDictionary *parameters = [self generateDefaultParameters];
            parameters[@"name"] = self.name;
            parameters[@"freeToEdit"] = self.freeToEdit;
            parameters[@"picture"] = self.picture;
            [[self API] PUT:[NSString stringWithFormat:@"groups/%@", self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self.editableManagedObjectContext performBlock:^{
                    [self updateWithData:responseObject];
                    SaveManagedObjectContext(self.editableManagedObjectContext);
                    requestSucceedWithBlock(operation, parameters, success);
                }];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                requestFailedWithBlock(operation, parameters, error, failure);
            }];
        } failure:failure];
    };
    [[self API] uploadImage:image withCompletionBlock:^(NSString *response, NSError *error) {
        if (error) {
            if (failure) failure(error);
        } else {
            requestBlock(response);
        }
    }];
}

- (void)deleteWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [self.editableManagedObjectContext performBlock:^{
        self.editableObject.removed = @YES;
        SaveManagedObjectContext(self.editableManagedObjectContext);
    }];
    
    if (self.isDefaultValue) {
        if (success) success();
        return;
    }
    
    [[self API] ensureAuthenticationWithSuccess:^{
        if (self.owner.isMe) {
            NSMutableDictionary *parameters = [self generateDefaultParameters];
            [[self API] DELETE:[NSString stringWithFormat:@"groups/%@", self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self.editableManagedObjectContext performBlock:^{
                    [self.editableManagedObjectContext deleteObject:self.editableObject];
                    SaveManagedObjectContext(self.editableManagedObjectContext);
                    requestSucceedWithBlock(operation, parameters, success);
                }];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self.editableManagedObjectContext performBlock:^{
                    self.editableObject.removed = @NO;
                    SaveManagedObjectContext(self.editableManagedObjectContext);
                }];
                requestFailedWithBlock(operation, parameters, error, failure);
            }];
        } else {
            [self updateMembersWithSuccess:^(id response) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    Membership *membership = [self.members filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"user.rid = %@", [User currentUser].rid]].anyObject;
                    if (!membership) {
                        if (success) success();
                        return;
                    }
                    NSMutableDictionary *parameters = [self generateDefaultParameters];
                    [[self API] DELETE:[NSString stringWithFormat:@"groups/%@/members/%@", self.rid, membership.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        [self.editableManagedObjectContext performBlock:^{
                            [self.editableManagedObjectContext deleteObject:self.editableObject];
                            SaveManagedObjectContext(self.editableManagedObjectContext);
                            requestSucceedWithBlock(operation, parameters, success);
                        }];
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        [self.editableManagedObjectContext performBlock:^{
                            self.editableObject.removed = @NO;
                            SaveManagedObjectContext(self.editableManagedObjectContext);
                        }];
                        requestFailedWithBlock(operation, parameters, error, failure);
                    }];
                });
            } failure:failure];
        }
    } failure:failure];
}

- (NSString *)sharingText {
    NSString *sharingUrl = [NSString stringWithFormat:@"http://footbl.co/groups/%@", self.code];
    return [NSString stringWithFormat:NSLocalizedString(@"Join my group on Footbl! Access %@ or use the code %@", @"@{group_share_url} {group_code}"), sharingUrl, self.code];
}

@end
