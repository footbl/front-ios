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

+ (void)createWithChampionship:(Championship *)championship name:(NSString *)name members:(NSArray *)members success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        parameters[@"name"] = name;
        parameters[@"championship"] = championship.rid;
        [[self API] POST:@"groups" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.editableManagedObjectContext performBlock:^{
                Group *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.editableManagedObjectContext];
                group.rid = responseObject[kAPIIdentifierKey];
                [group updateWithData:responseObject];
                requestSucceedWithBlock(operation, parameters, nil);
                SaveManagedObjectContext(self.editableManagedObjectContext);
                [group addMembers:members success:success failure:failure];
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
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

#pragma mark - Instance Methods

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    self.name = data[@"name"];
    self.freeToEdit = data[@"freeToEdit"];
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

- (void)updateMembersWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    NSString *key = [NSString stringWithFormat:@"%@%@", self.rid, API_DICTIONARY_KEY];
    [[self API] groupOperationsWithKey:key block:^{
        if (self.isDefaultValue) {
            [[self API] ensureAuthenticationWithSuccess:^{
                NSMutableDictionary *parameters = [self generateParametersWithPage:API_CURRENT_PAGE(key)];
                [[self API] GET:[NSString stringWithFormat:@"championships/%@/ranking", self.championship.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    API_APPEND_RESULT(responseObject, key);
                    if ([[operation responseObject] count] == [self responseLimit]) {
                        API_APPEND_PAGE(key);
                        [FootblAPI performOperationWithoutGrouping:^{
                            [self updateMembersWithSuccess:success failure:failure];
                        }];
                    } else {
                        NSMutableArray *realMembers = [NSMutableArray new];
                        for (NSDictionary *member in API_RESULT(key)) {
                            if ([member[@"ranking"] isKindOfClass:[NSNumber class]]) {
                                [realMembers addObject:member];
                            }
                        }
                        SPLogVerbose(@"%@", realMembers);
                        [Membership loadContent:realMembers inManagedObjectContext:self.managedObjectContext usingCache:self.members enumeratingObjectsWithBlock:^(Membership *membership, NSDictionary *contentEntry) {
                            membership.group = self;
                        } deletingUntouchedObjectsWithBlock:^(NSSet *untouchedObjects) {
                            [self.managedObjectContext deleteObjects:untouchedObjects];
                        }];
                        [[self API] finishGroupedOperationsWithKey:key error:nil];
                        requestSucceedWithBlock(operation, parameters, nil);
                        API_RESET_KEY(key);
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [[self API] finishGroupedOperationsWithKey:key error:error];
                    requestFailedWithBlock(operation, parameters, error, nil);
                    API_RESET_KEY(key);
                }];
            } failure:^(NSError *error) {
                [[self API] finishGroupedOperationsWithKey:key error:error];
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
                        [[self API] finishGroupedOperationsWithKey:key error:nil];
                        requestSucceedWithBlock(operation, parameters, nil);
                        API_RESET_KEY(key);
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [[self API] finishGroupedOperationsWithKey:key error:error];
                    requestFailedWithBlock(operation, parameters, error, nil);
                    API_RESET_KEY(key);
                }];
            } failure:^(NSError *error) {
                [[self API] finishGroupedOperationsWithKey:key error:error];
                API_RESET_KEY(key);
            }];
        }
    } success:success failure:failure];
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

- (void)deleteWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        [self.editableManagedObjectContext performBlock:^{
            self.editableObject.removed = @YES;
            SaveManagedObjectContext(self.editableManagedObjectContext);
        }];
        
        if (self.isDefaultValue) {
            if (success) success();
            return;
        }
        
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
    } failure:failure];
}

@end
