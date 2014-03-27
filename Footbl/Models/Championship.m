//
//  Championship.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/26/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "AppDelegate.h"
#import "Championship.h"
#import "Team.h"

@interface Championship ()

@end

#pragma mark Championship

@implementation Championship

#pragma mark - Class Methods

+ (void)updateWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [[self API] GET:@"championships" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self loadContent:responseObject inManagedObjectContext:FootblBackgroundManagedObjectContext() usingCache:nil enumeratingObjectsWithBlock:nil deletingUntouchedObjectsWithBlock:^(NSSet *untouchedObjects) {
                [FootblBackgroundManagedObjectContext() deleteObjects:untouchedObjects];
            }];
            requestSucceedWithBlock(responseObject, success);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

#pragma mark - Instance Methods

- (void)updateWithData:(NSDictionary *)data {
    self.name = [data objectForKey:@"name"];
    
    [Team loadContent:[data objectForKey:@"competitors"] inManagedObjectContext:self.managedObjectContext usingCache:self.competitors enumeratingObjectsWithBlock:^(Team *object, NSDictionary *contentEntry) {
        [object addChampionshipsObject:self];
    } deletingUntouchedObjectsWithBlock:^(NSSet *untouchedObjects) {
        [untouchedObjects makeObjectsPerformSelector:@selector(removeChampionshipsObject:) withObject:self];
    }];
}

- (void)updateWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [[self API] GET:[@"championships/" stringByAppendingString:self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self updateWithData:responseObject];
            SaveManagedObjectContext(self.managedObjectContext);
            requestSucceedWithBlock(responseObject, success);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

@end
