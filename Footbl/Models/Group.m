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

+ (void)createWithChampionship:(Championship *)championship name:(NSString *)name success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        parameters[@"name"] = name;
        parameters[@"championship"] = championship.rid;
        [[self API] POST:@"groups" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.editableManagedObjectContext performBlock:^{
                Group *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.editableManagedObjectContext];
                group.rid = responseObject[kAPIIdentifierKey];
                [group updateWithData:responseObject];
                SaveManagedObjectContext(self.editableManagedObjectContext);
                requestSucceedWithBlock(operation, parameters, success);
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
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
    
    NSString *championshipRid = data[@"championship"];
    if ([championshipRid isKindOfClass:[NSDictionary  class]]) {
        championshipRid = data[@"championship"][kAPIIdentifierKey];
    }
    self.championship = [Championship findByIdentifier:championshipRid inManagedObjectContext:self.managedObjectContext];
}

- (void)updateMembersWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [[self API] GET:[NSString stringWithFormat:@"groups/%@/members", self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [Membership loadContent:responseObject inManagedObjectContext:self.managedObjectContext usingCache:self.members enumeratingObjectsWithBlock:^(Membership *membership, NSDictionary *contentEntry) {
                membership.group = self;
            } deletingUntouchedObjectsWithBlock:^(NSSet *untouchedObjects) {
                [self.managedObjectContext deleteObjects:untouchedObjects];
            }];
            requestSucceedWithBlock(operation, parameters, success);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
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
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [[self API] DELETE:[NSString stringWithFormat:@"groups/%@", self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.editableManagedObjectContext performBlock:^{
                [self.editableManagedObjectContext deleteObject:self.editableObject];
                SaveManagedObjectContext(self.editableManagedObjectContext);
                requestSucceedWithBlock(operation, parameters, success);
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

@end
