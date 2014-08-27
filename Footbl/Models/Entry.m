//
//  Entry.m
//  Footbl
//
//  Created by Fernando Saragoça on 8/14/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "Championship.h"
#import "Entry.h"
#import "User.h"

#pragma mark Entry

@implementation Entry

#pragma mark - Class Methods

+ (NSString *)resourcePath {
    return @"entries";
}

+ (void)createWithParameters:(NSDictionary *)parameters success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[FTCoreDataStore privateQueueContext] performBlock:^{
        Championship *championship = [Championship findWithObject:parameters[@"championship"] inContext:[FTCoreDataStore privateQueueContext]];
        championship.enabled = @YES;
        [[FTCoreDataStore privateQueueContext] performSave];
    }];
    
    [super createWithParameters:parameters success:success failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[FTCoreDataStore privateQueueContext] performBlock:^{
            Championship *championship = [Championship findWithObject:parameters[@"championship"] inContext:[FTCoreDataStore privateQueueContext]];
            championship.enabled = @NO;
            [[FTCoreDataStore privateQueueContext] performSave];
        }];
        if (failure) failure(operation, error);
    }];
}

#pragma mark - Instance Methods

- (NSString *)resourcePath {
    return [[[self class] resourcePathWithObject:[User currentUser]] stringByAppendingPathComponent:self.slug];
}

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    self.championship = [Championship findOrCreateWithObject:data[@"championship"] inContext:self.managedObjectContext];
    self.championship.enabled = @YES;
}

- (void)deleteWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    [[FTCoreDataStore privateQueueContext] performBlock:^{
        self.championship.enabled = @NO;
        [[FTCoreDataStore privateQueueContext] performSave];
    }];
    
    [super deleteWithSuccess:success failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[FTCoreDataStore privateQueueContext] performBlock:^{
            self.championship.enabled = @YES;
            [[FTCoreDataStore privateQueueContext] performSave];
        }];
        if (failure) failure(operation, error);
    }];
}

@end
