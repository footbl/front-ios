//
//  Comment.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/26/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <TransformerKit/TransformerKit.h>
#import "Championship.h"
#import "Comment.h"
#import "Match.h"
#import "User.h"

@interface Comment ()

@end

#pragma mark Comment

@implementation Comment

#pragma mark - Class Methods

+ (NSString *)resourcePath {
    SPLogError(@"Comment resource path should not be used.");
    return @"championships/%@/matches";
}

+ (void)updateFromMatch:(Match *)match success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    NSString *key = [NSString stringWithFormat:@"%@%@", match.rid, API_DICTIONARY_KEY];
    [[self API] groupOperationsWithKey:key block:^{
        [[self API] ensureAuthenticationWithSuccess:^{
            NSMutableDictionary *parameters = [self generateParametersWithPage:API_CURRENT_PAGE(key)];
            [[self API] GET:[NSString stringWithFormat:@"championships/%@/matches/%@/comments", match.championship.rid, match.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                API_APPEND_RESULT(responseObject, key);
                if ([[operation responseObject] count] == [self responseLimit]) {
                    API_APPEND_PAGE(key);
                    [FootblAPI performOperationWithoutGrouping:^{
                        [self updateFromMatch:match success:success failure:failure];
                    }];
                } else {
                    [self loadContent:API_RESULT(key) inManagedObjectContext:self.editableManagedObjectContext usingCache:match.comments enumeratingObjectsWithBlock:^(Comment *comment, NSDictionary *contentEntry) {
                        comment.match = match;
                    } deletingUntouchedObjectsWithBlock:^(NSSet *untouchedObjects) {
                        [self.editableManagedObjectContext deleteObjects:untouchedObjects];
                    }];
                    requestSucceedWithBlock(operation, parameters, nil);
                    [[self API] finishGroupedOperationsWithKey:key error:nil];
                    API_RESET_KEY(key);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                requestFailedWithBlock(operation, parameters, error, nil);
                [[self API] finishGroupedOperationsWithKey:key error:error];
                API_RESET_KEY(key);
            }];
        } failure:^(NSError *error) {
            [[self API] finishGroupedOperationsWithKey:key error:error];
        }];
    } success:success failure:failure];
}

+ (void)createCommentInMatch:(Match *)match withMessage:(NSString *)message success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        parameters[@"message"] = message;
        NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName];
        parameters[@"date"] = [transformer transformedValue:[NSDate date]];
        [[self API] POST:[NSString stringWithFormat:@"championships/%@/matches/%@/comments", match.championship.rid, match.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.editableManagedObjectContext performBlock:^{
                Comment *comment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:self.editableManagedObjectContext];
                comment.match = match;
                comment.rid = responseObject[kAPIIdentifierKey];
                [comment updateWithData:responseObject];
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
    
    NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName];
    self.date = [transformer reverseTransformedValue:data[@"date"]];
    self.message = data[@"message"];
    self.user = [User findOrCreateByIdentifier:data[@"user"] inManagedObjectContext:self.managedObjectContext];
}

@end
