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

+ (void)updateWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [[self API] GET:@"groups" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self loadContent:responseObject inManagedObjectContext:self.editableManagedObjectContext usingCache:nil enumeratingObjectsWithBlock:nil deletingUntouchedObjectsWithBlock:^(NSSet *untouchedObjects) {
                [self.editableManagedObjectContext deleteObjects:untouchedObjects];
            }];
            requestSucceedWithBlock(operation, parameters, success);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

+ (void)createWithChampionship:(Championship *)championship name:(NSString *)name success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [parameters setObject:name forKey:@"name"];
        [parameters setObject:championship.rid forKey:@"championship"];
        [[self API] POST:@"groups" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.editableManagedObjectContext performBlock:^{
                Group *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.editableManagedObjectContext];
                group.rid = [responseObject objectForKey:kAPIIdentifierKey];
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
    self.name = [data objectForKey:@"name"];
    self.freeToEdit = [data objectForKey:@"freeToEdit"];
    self.owner = [User findOrCreateByIdentifier:[data objectForKey:@"owner"] inManagedObjectContext:self.managedObjectContext];
    if ([[data objectForKey:@"owner"] isKindOfClass:[NSDictionary class]]) {
        [self.owner updateWithData:[data objectForKey:@"owner"]];
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Championship"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSString *championshipRid = [data objectForKey:@"championship"];
    if ([championshipRid isKindOfClass:[NSDictionary  class]]) {
        championshipRid = [[data objectForKey:@"championship"] objectForKey:kAPIIdentifierKey];
    }
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"rid IN %@", @[championshipRid]];
    NSError *error = nil;
    NSArray *fetchResult = [self.editableManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    self.championships = [NSSet setWithArray:fetchResult];
}

- (void)updateWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [[self API] GET:[NSString stringWithFormat:@"groups/%@", self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.editableManagedObjectContext performBlock:^{
                [self updateWithData:responseObject];
                SaveManagedObjectContext(self.editableManagedObjectContext);
                requestSucceedWithBlock(operation, parameters, success);
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
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
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [parameters setObject:self.name forKey:@"name"];
        [parameters setObject:self.freeToEdit forKey:@"freeToEdit"];
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
