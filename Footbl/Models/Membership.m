//
//  Membership.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/04/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "Group.h"
#import "Membership.h"
#import "User.h"

@interface Membership ()

@end

@implementation Membership

#pragma mark - Class Methods

+ (NSString *)resourcePath {
    return @"members";
}

+ (NSArray *)enabledProperties {
    return [[super enabledProperties] arrayByAddingObjectsFromArray:@[@"previousRanking", @"ranking", @"notifications"]];
}

+ (void)getWithObject:(Group *)group success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    NSString *path = [self resourcePathWithObject:group];
    [[FTOperationManager sharedManager] GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[self class] loadContent:responseObject inManagedObjectContext:[FTCoreDataStore privateQueueContext] usingCache:group.members enumeratingObjectsWithBlock:^(Membership *membership, NSDictionary *data) {
            membership.group = group.editableObject;
        } untouchedObjectsBlock:^(NSSet *untouchedObjects) {
            [[FTCoreDataStore privateQueueContext] deleteObjects:untouchedObjects];
        } completionBlock:success];
    } failure:failure];
}

+ (void)createWithParameters:(NSDictionary *)parameters success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    NSString *path = [[[Group resourcePath] stringByAppendingPathComponent:[parameters[kFTRequestParamResourcePathObject] slug]] stringByAppendingPathComponent:[self resourcePath]];
    NSMutableDictionary *mutableParameters = [parameters mutableCopy];
    if (mutableParameters[kFTRequestParamResourcePathObject]) {
        [mutableParameters removeObjectForKey:kFTRequestParamResourcePathObject];
    }
    [[FTOperationManager sharedManager] POST:path parameters:mutableParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[FTCoreDataStore privateQueueContext] performBlock:^{
            FTModel *object = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:[FTCoreDataStore privateQueueContext]];
            [object updateWithData:responseObject];
            [[FTCoreDataStore privateQueueContext] performSave];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) success(object.editableObject);
            });
        }];
    } failure:failure];
}

#pragma mark - Instance Methods

- (void)setNotificationsEnabled:(BOOL)enabled success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    if (self.notificationsValue == enabled) {
        return;
    }
    
    [[FTCoreDataStore privateQueueContext] performBlock:^{
        self.editableObject.notificationsValue = enabled;
        [[FTCoreDataStore privateQueueContext] performSave];
    }];
    
    [[FTOperationManager sharedManager] PUT:self.resourcePath parameters:@{@"notifications" : @(enabled)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) success(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[FTCoreDataStore privateQueueContext] performBlock:^{
            self.editableObject.notificationsValue = !enabled;
            [[FTCoreDataStore privateQueueContext] performSave];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) failure(operation, error);
            });
        }];
    }];
}

- (NSString *)resourcePath {
    return [[[self class] resourcePathWithObject:self.group] stringByAppendingPathComponent:self.slug];
}

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    self.user = [User findOrCreateWithObject:data[@"user"] inContext:self.managedObjectContext];
    
    if (self.ranking) {
        self.hasRanking = @YES;
    } else {
        self.hasRanking = @NO;
    }
}

@end
