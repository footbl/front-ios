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
    return [[super enabledProperties] arrayByAddingObjectsFromArray:@[@"payed", @"value"]];
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
        [[[self class] editableManagedObjectContext] performBlock:^{
            FTModel *object = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:[self editableManagedObjectContext]];
            [object updateWithData:responseObject];
            [[self editableManagedObjectContext] performSave];
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
        parameters[@"value"] = @(100 - [User currentUser].fundsValue);
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
        [[self class] loadContent:responseObject inManagedObjectContext:[[self class] editableManagedObjectContext] usingCache:nil enumeratingObjectsWithBlock:nil untouchedObjectsBlock:^(NSSet *untouchedObjects) {
            [[self editableManagedObjectContext] deleteObjects:[untouchedObjects filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"creditedUser = %@", object]]];
        } completionBlock:success];
    } failure:failure];
}

+ (void)getRequestsWithObject:(FTModel *)object success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    NSString *path = [NSString stringWithFormat:@"users/%@/requested-credits", object.slug];
    [[FTOperationManager sharedManager] GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[self class] loadContent:responseObject inManagedObjectContext:[[self class] editableManagedObjectContext] usingCache:nil enumeratingObjectsWithBlock:nil untouchedObjectsBlock:^(NSSet *untouchedObjects) {
            [[self editableManagedObjectContext] deleteObjects:untouchedObjects];
        } completionBlock:success];
    } failure:failure];
}

#pragma mark - Instance Methods

- (NSString *)resourcePath {
    return [[[self class] resourcePathWithObject:self.creditedUser] stringByAppendingPathComponent:self.slug];
}

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    self.chargedUser = [User findOrCreateWithObject:data[@"chargedUser"] inContext:self.managedObjectContext];
    self.creditedUser = [User findOrCreateWithObject:data[@"creditedUser"] inContext:self.managedObjectContext];
}

@end
