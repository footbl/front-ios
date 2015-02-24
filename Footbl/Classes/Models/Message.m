//
//  Message.m
//  Footbl
//
//  Created by Fernando Saragoça on 11/22/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

@import AudioToolbox;
#import <TransformerKit/TTTDateTransformers.h>
#import "Group.h"
#import "Message.h"
#import "User.h"

@interface Message ()

@end

#pragma mark Message

@implementation Message

#pragma mark - Class Methods

+ (NSArray *)enabledProperties {
    [super enabledProperties];
    return @[@"date", @"updatedAt", @"message"];
}

+ (NSString *)resourcePath {
    return @"messages";
}

+ (void)getWithGroup:(Group *)group page:(NSUInteger)page shouldDeleteUntouchedObjects:(BOOL)shouldDeleteUntouchedObjects success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    NSString *path = [self resourcePathWithObject:group];
    
    [[FTOperationManager sharedManager] performOperationWithOptions:FTRequestOptionGroupRequests | FTRequestOptionAuthenticationRequired operations:^{
        [[FTOperationManager sharedManager] GET:path parameters:@{@"page" : @(page)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[self class] loadContent:responseObject inManagedObjectContext:[FTCoreDataStore privateQueueContext] usingCache:group.messages enumeratingObjectsWithBlock:^(Message *message, NSDictionary *data) {
                message.group = group.editableObject;
            } untouchedObjectsBlock:^(NSSet *untouchedObjects) {
                if (shouldDeleteUntouchedObjects) {
                    [[FTCoreDataStore privateQueueContext] deleteObjects:[untouchedObjects filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"deliveryFailed = %@", @NO]]];
                }
            } completionBlock:^(NSArray *objects) {
                if (objects.count == FT_API_PAGE_LIMIT) {
                    if (success) success(@(page + 1));
                } else {
                    if (success) success(nil);
                }
            }];
        } failure:failure];
    }];
}

+ (void)markAsReadFromGroup:(Group *)group success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    NSNumber *unreadCount = [group.unreadMessagesCount copy];
    [[FTCoreDataStore privateQueueContext] performBlock:^{
        group.editableObject.unreadMessagesCount = @0;
        [[FTCoreDataStore privateQueueContext] performSave];
    }];
    
    [[FTOperationManager sharedManager] PUT:[[[self class] resourcePathWithObject:group] stringByAppendingPathComponent:@"all/mark-as-read"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) success(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[FTCoreDataStore privateQueueContext] performBlock:^{
            group.editableObject.unreadMessagesCount = unreadCount;
            [[FTCoreDataStore privateQueueContext] performSave];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) failure(operation, error);
            });
        }];
    }];
}

+ (void)createWithParameters:(NSDictionary *)parameters success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    NSMutableDictionary *mutableParameters = [parameters mutableCopy];
    Group *group = [mutableParameters[kFTRequestParamResourcePathObject] editableObject];
    [mutableParameters removeObjectForKey:kFTRequestParamResourcePathObject];
    
    __block Message *message;
    [[FTCoreDataStore privateQueueContext] performBlock:^{
        message = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:[FTCoreDataStore privateQueueContext]];
        message.group = group;
        message.user = [User currentUser].editableObject;
        message.createdAt = [NSDate date];
        message.message = parameters[@"message"];
        message.rid = message.message;
        message.slug = message.message;
        message.typeString = parameters[@"type"];
        [[FTCoreDataStore privateQueueContext] performSave]; 
    }];
    
    NSString *path = [self resourcePathWithObject:group];
    [[FTOperationManager sharedManager] performOperationWithOptions:FTRequestOptionAuthenticationRequired operations:^{
        [[FTOperationManager sharedManager] POST:path parameters:mutableParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[FTCoreDataStore privateQueueContext] performBlock:^{
                message.rid = responseObject[kFTResponseParamIdentifier];
                message.slug = responseObject[kFTResponseParamIdentifier];
                [message updateWithData:responseObject];
                [[FTCoreDataStore privateQueueContext] performSave];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) success(message);
                });
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[FTCoreDataStore privateQueueContext] performBlock:^{
                message.deliveryFailed = @YES;
                [[FTCoreDataStore privateQueueContext] performSave];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failure) failure(operation, error);
                });
            }];
        }];
    }];
}

+ (void)handleRemoteNotification:(NSDictionary *)notification {
    NSString *key = [[[notification objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"loc-key"];
    if ([key isEqualToString:@"NOTIFICATION_GROUP_MESSAGE"]) {
        NSString *groupSlug = [[[[notification objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"loc-args"] lastObject];
        Group *group = [Group findWithObject:groupSlug inContext:[FTCoreDataStore privateQueueContext]];
        Message *lastMessage = [group.messages sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]].firstObject;
        [group getUnreadMessageCountWithSuccess:^(id response) {
            [Message getWithGroup:group page:0 shouldDeleteUntouchedObjects:NO success:^(NSArray *messages) {
                NSSet *newMessages = [group.messages filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"createdAt > %@ AND user.slug != %@", lastMessage.createdAt, [User currentUser].slug]];
                if (newMessages.count > 0) {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                }
            } failure:nil];
        } failure:nil];
    }
}

#pragma mark - Instance Methods

- (void)deliverWithSuccess:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    NSString *path = [Message resourcePathWithObject:self.group];
    [[FTOperationManager sharedManager] performOperationWithOptions:FTRequestOptionAuthenticationRequired operations:^{
        [[FTOperationManager sharedManager] POST:path parameters:@{@"message" : self.message, @"type" : self.typeString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[FTCoreDataStore privateQueueContext] performBlock:^{
                self.rid = responseObject[kFTResponseParamIdentifier];
                self.slug = responseObject[kFTResponseParamIdentifier];
                [self updateWithData:responseObject];
                self.deliveryFailed = @NO;
                [[FTCoreDataStore privateQueueContext] performSave];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Message markAsReadFromGroup:self.group success:nil failure:nil];
                    if (success) success(self);
                });
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[FTCoreDataStore privateQueueContext] performBlock:^{
                self.deliveryFailed = @YES;
                [[FTCoreDataStore privateQueueContext] performSave];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failure) failure(operation, error);
                });
            }];
        }];
    }];
}

- (NSString *)resourcePath {
    return [[[self class] resourcePathWithObject:self.group] stringByAppendingPathComponent:self.slug];
}

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:@{}];
    
    if (data[kFTResponseParamIdentifier]) {
        self.rid = data[kFTResponseParamIdentifier];
        self.slug = data[kFTResponseParamIdentifier];
    }
    
    NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName];
    if (!self.createdAt) {
        self.createdAt = [transformer reverseTransformedValue:data[@"createdAt"]];
    }
    self.updatedAt = [transformer reverseTransformedValue:data[@"updatedAt"]];
    
    self.user = [User findOrCreateWithObject:data[@"user"] inContext:self.managedObjectContext];
    self.message = data[@"message"];
    self.typeString = data[@"type"];
}

@end