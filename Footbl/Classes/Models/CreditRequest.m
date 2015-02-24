//
//  CreditRequest.m
//  Footbl
//
//  Created by Fernando Saragoça on 8/14/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "CreditRequest.h"
#import "User.h"

#pragma mark CreditRequest

@implementation CreditRequest

#pragma mark - Class Methods

+ (NSArray *)enabledProperties {
    return [[super enabledProperties] arrayByAddingObjectsFromArray:@[@"payed"]];
}

+ (NSString *)resourcePath {
    return @"credit-requests";
}

+ (void)createWithParameters:(NSDictionary *)parameters success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    NSString *path = [NSString stringWithFormat:@"users/%@/credit-requests", parameters[kFTRequestParamResourcePathObject]];
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

+ (void)createWithIds:(NSArray *)ids success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    if (ids.count == 0) {
        if (success) success(self);
        return;
    }
    __block NSMutableArray *pendingIds = [ids mutableCopy];
    __block NSError *operationError = nil;
    [ids enumerateObjectsUsingBlock:^(NSString *userId, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *parameters = [NSMutableDictionary new];
        parameters[kFTRequestParamResourcePathObject] = userId;
        [CreditRequest createWithParameters:parameters success:^(id response) {
            [pendingIds removeObject:userId];
            if (pendingIds.count == 0) {
                if (operationError) {
                    if (failure) failure(nil, operationError);
                } else {
                    if (success) success(self);
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            operationError = error;
            [pendingIds removeObject:userId];
            if (pendingIds.count == 0) {
                if (failure) failure(nil, operationError);
            }
        }];
    }];
}

+ (void)getWithObject:(FTModel *)object success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    NSString *path = [self resourcePathWithObject:object];
    [[FTOperationManager sharedManager] GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[self class] loadContent:responseObject inManagedObjectContext:[FTCoreDataStore privateQueueContext] usingCache:nil enumeratingObjectsWithBlock:nil untouchedObjectsBlock:^(NSSet *untouchedObjects) {
            [[FTCoreDataStore privateQueueContext] deleteObjects:[untouchedObjects filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"chargedUser = %@", object]]];
        } completionBlock:success];
    } failure:failure];
}

+ (void)getRequestsWithObject:(FTModel *)object success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    NSString *path = [NSString stringWithFormat:@"users/%@/requested-credits", object.slug];
    [[FTOperationManager sharedManager] GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[self class] loadContent:responseObject inManagedObjectContext:[FTCoreDataStore privateQueueContext] usingCache:nil enumeratingObjectsWithBlock:nil untouchedObjectsBlock:^(NSSet *untouchedObjects) {
            [[FTCoreDataStore privateQueueContext] deleteObjects:[untouchedObjects filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"creditedUser = %@", object]]];
        } completionBlock:success];
    } failure:failure];
}

+ (void)payRequests:(NSArray *)requests success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    if (requests.count == 0) {
        if (success) success(self);
        return;
    }
    __block NSMutableArray *pendingIds = [requests mutableCopy];
    __block NSError *operationError = nil;
    [requests enumerateObjectsUsingBlock:^(CreditRequest *request, NSUInteger idx, BOOL *stop) {
        NSString *path = [NSString stringWithFormat:@"users/%@/credit-requests/%@/approve", [User currentUser].slug, request.slug];
        [[FTOperationManager sharedManager] PUT:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [pendingIds removeObject:request];
            if (pendingIds.count == 0) {
                if (operationError) {
                    if (failure) failure(nil, operationError);
                } else {
                    if (success) success(self);
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            operationError = error;
            [pendingIds removeObject:request];
            if (pendingIds.count == 0) {
                if (failure) failure(nil, operationError);
            }
        }];
    }];
}

#pragma mark - Instance Methods

- (NSString *)resourcePath {
    return [[[self class] resourcePathWithObject:self.creditedUser] stringByAppendingPathComponent:self.slug];
}

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    self.chargedUser = [User findOrCreateWithObject:data[@"chargedUser"] inContext:self.managedObjectContext];
    self.creditedUser = [User findOrCreateWithObject:data[@"creditedUser"] inContext:self.managedObjectContext];
    
    if (!self.chargedUser) {
        self.facebookId = data[@"chargedUser"][@"facebookId"];
    } else if (!self.creditedUser) {
        self.facebookId = data[@"creditedUser"][@"facebookId"];
    }
    
    self.value = @(MAX(0, 100 - [data[@"creditedUser"][@"funds"] integerValue] - [data[@"creditedUser"][@"stake"] integerValue]));
}

@end
