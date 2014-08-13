//
//  Group.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/04/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "FootblModel.h"
#import "FTImageUploader.h"
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

+ (void)createWithParameters:(NSDictionary *)parameters success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [super createWithParameters:parameters success:^(id response) {
        
    } failure:failure];
}

+ (void)createName:(NSString *)name image:(UIImage *)image members:(NSArray *)members invitedMembers:(NSArray *)invitedMembers success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [FTImageUploader uploadImage:image withCompletion:^(NSString *imagePath, NSError *error) {
        NSMutableDictionary *parameters = [NSMutableDictionary new];
        parameters[@"name"] = name;
        if (imagePath) {
            parameters[@"picture"] = imagePath;
        }
        [self createWithParameters:parameters success:^(Group *group) {
            __weak typeof(Group *)weakGroup = group;
            [group addMembers:members success:^(id response) {
                [weakGroup addInvitedMembers:invitedMembers success:^(id response) {
                    [weakGroup updateMembersWithSuccess:^(id response) {
                        if (success) success(weakGroup);
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        if (success) success(weakGroup);
                    }];
                } failure:failure];
            } failure:failure];
        } failure:failure];
    }];
}

+ (void)getWithObject:(FTModel *)object success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[FTOperationManager sharedManager] GET:[self resourcePath] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self loadContent:responseObject inManagedObjectContext:[self editableManagedObjectContext] usingCache:nil enumeratingObjectsWithBlock:nil untouchedObjectsBlock:^(NSSet *untouchedObjects) {
            [[self editableManagedObjectContext] deleteObjects:[untouchedObjects filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"isDefault = %@", @NO]]];
        } completionBlock:success];
    } failure:failure];
}

+ (void)joinGroupWithCode:(NSString *)code success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [self getWithObject:nil success:^(id response) {
        Group *group = [Group findWithObject:code inContext:[self editableManagedObjectContext]];
        if (group) {
            if (success) success(group);
        }
        
        [[FTOperationManager sharedManager] GET:[NSString stringWithFormat:@"groups/%@", code] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[self editableManagedObjectContext] performBlock:^{
                Group *group = [Group findOrCreateWithObject:responseObject inContext:[self editableManagedObjectContext]];
                [Membership createWithParameters:@{kFTRequestParamResourcePathObject : group, @"user" : @"me"} success:^(id response) {
                    [[self editableManagedObjectContext] performSave];
                    if (success) success(group);
                } failure:failure];
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (failure) failure(operation, [NSError errorWithDomain:kFTErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"Error: group not found", @"")}]);
        }];
    } failure:failure];
}

#pragma mark - Instance Methods

- (void)saveStatusInLocalDatabase {
    NSMutableDictionary *localDatabase = [[[NSUserDefaults standardUserDefaults] objectForKey:@"groups"] mutableCopy];
    if (!localDatabase) {
        localDatabase = [NSMutableDictionary new];
    }
    localDatabase[self.rid] = self.isNew;
    [[NSUserDefaults standardUserDefaults] setObject:localDatabase forKey:@"groups"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    self.owner = [User findOrCreateWithObject:data[@"owner"] inContext:self.managedObjectContext];
    
    NSDictionary *localDatabase = [[NSUserDefaults standardUserDefaults] objectForKey:@"groups"];
    if (self.isNewValue) {
        if (localDatabase[self.rid]) {
            self.isNew = localDatabase[self.rid];
        }
    }
}

- (void)addMembers:(NSArray *)members success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    if (members.count == 0) {
        if (success) success(self);
        return;
    }
    __block NSMutableArray *pendingMembers = [members mutableCopy];
    __block NSError *operationError = nil;
    [members enumerateObjectsUsingBlock:^(NSDictionary *user, NSUInteger idx, BOOL *stop) {
        [Membership createWithParameters:@{kFTRequestParamResourcePathObject : self, @"user" : user[kAPIIdentifierKey]} success:^(id response) {
            [pendingMembers removeObject:user];
            if (pendingMembers.count == 0) {
                if (operationError) {
                    if (failure) failure(nil, operationError);
                } else {
                    if (success) success(self);
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            operationError = error;
            [pendingMembers removeObject:user];
            if (pendingMembers.count == 0) {
                if (failure) failure(nil, operationError);
            }
        }];
    }];
}

- (void)addInvitedMembers:(NSArray *)members success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    if (members.count == 0) {
        if (success) success(self);
        return;
    }
    __block NSMutableArray *pendingMembers = [members mutableCopy];
    __block NSError *operationError = nil;
    [members enumerateObjectsUsingBlock:^(NSDictionary *user, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *parameters = [NSMutableDictionary new];
        if ([user isKindOfClass:[NSDictionary class]]) {
            parameters[@"facebookId"] = user[@"id"];
        } else {
            parameters[@"email"] = user;
        }
        parameters[kFTRequestParamResourcePathObject] = self;
        [Membership createWithParameters:parameters success:^(id response) {
            [pendingMembers removeObject:user];
            if (pendingMembers.count == 0) {
                if (operationError) {
                    if (failure) failure(nil, operationError);
                } else {
                    if (success) success(self);
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            operationError = error;
            [pendingMembers removeObject:user];
            if (pendingMembers.count == 0) {
                if (failure) failure(nil, operationError);
            }
        }];
    }];
}

- (void)cancelMembersUpdate {
    NSString *key = [NSString stringWithFormat:@"%@updateMembersWithSuccess:", self.rid];
    API_RESET_KEY(key);
}

- (void)updateMembersWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    #warning FIX Default groups
    [Membership getWithObject:self.editableObject success:success failure:failure];
}

- (void)saveWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[[self class] editableManagedObjectContext] performBlock:^{
        [[[self class] editableManagedObjectContext] performSave];
    }];
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"name"] = self.name;
    parameters[@"freeToEdit"] = self.freeToEdit;
    if (self.picture) {
        parameters[@"picture"] = self.picture;
    }
    [self updateWithParameters:parameters success:success failure:failure];
}

- (void)uploadImage:(UIImage *)image success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [FTImageUploader uploadImage:image withCompletion:^(NSString *imagePath, NSError *error) {
            self.picture = imagePath;
            
            [[[self class] editableManagedObjectContext] performBlock:^{
                [[[self class] editableManagedObjectContext] performSave];
            }];
            
        NSMutableDictionary *parameters = [NSMutableDictionary new];
        parameters[@"name"] = self.name;
        parameters[@"freeToEdit"] = self.freeToEdit;
        if (self.picture) {
            parameters[@"picture"] = self.picture;
        }
        [self updateWithParameters:parameters success:success failure:failure];
    }];
}

- (void)deleteWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[[self class] editableManagedObjectContext] performBlock:^{
        self.editableObject.removed = @YES;
        [[[self class] editableManagedObjectContext] performSave];
    }];
    
    if (self.isDefaultValue) {
        if (success) success(nil);
        return;
    }
    
    [super deleteWithSuccess:success failure:failure];
    
#warning Fix not owned groups
    /*
    if (self.owner.isMe) {
        [super deleteWithSuccess:success failure:failure];
    } else {
        [self updateMembersWithSuccess:^(id response) {
            Membership *membership = [response filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"user.rid = %@", [User currentUser].rid]].anyObject;
            if (!membership) {
                if (success) success(nil);
                return;
            }
            [membership deleteWithSuccess:success failure:failure];
        } failure:failure];
    }
    */
}

- (NSString *)sharingText {
    if (self.isDefaultValue) {
        return [NSString stringWithFormat:NSLocalizedString(@"Join my group on Footbl! http://footbl.co/dl", @"")];
    } else {
        NSString *sharingUrl = [NSString stringWithFormat:@"http://footbl.co/groups/%@", self.slug];
        return [NSString stringWithFormat:NSLocalizedString(@"Join my group on Footbl! Access %@ or use the code %@", @"@{group_share_url} {group_code}"), sharingUrl, self.slug];
    }
}

@end
