//
//  Prize.m
//  Footbl
//
//  Created by Fernando Saragoça on 11/21/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "Prize.h"
#import "User.h"

@interface Prize ()

@end

#pragma mark Prize

@implementation Prize

#pragma mark - Class Methods

+ (NSArray *)enabledProperties {
    return [[super enabledProperties] arrayByAddingObjectsFromArray:@[@"value"]];
}

+ (NSString *)resourcePath {
    return @"prizes";
}

+ (void)getWithObject:(User *)user success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    NSString *path = [self resourcePathWithObject:user];
    [[FTOperationManager sharedManager] GET:path parameters:@{@"unreadMessages" : @YES} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[self class] loadContent:responseObject inManagedObjectContext:[FTCoreDataStore privateQueueContext] usingCache:nil enumeratingObjectsWithBlock:^(Prize *prize, NSDictionary *data) {
            prize.user = user.editableObject;
        } untouchedObjectsBlock:^(NSSet *untouchedObjects) {
            [[FTCoreDataStore privateQueueContext] deleteObjects:untouchedObjects];
        } completionBlock:success];
    } failure:failure];
}

#pragma mark - Instance Methods

- (NSString *)resourcePath {
    return [[[self class] resourcePathWithObject:self.user] stringByAppendingPathComponent:self.slug];
}

- (void)markAsReadWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[FTOperationManager sharedManager] PUT:[self.resourcePath stringByAppendingPathComponent:@"mark-as-read"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.user.editableObject getWithSuccess:^(id response) {
           [[FTCoreDataStore privateQueueContext] deleteObject:self.editableObject];
            if (success) success(nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[FTCoreDataStore privateQueueContext] deleteObject:self.editableObject];
            if (success) success(nil);
        }];
    } failure:failure];
}

@end
