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

@interface Comment ()

@end

#pragma mark Comment

@implementation Comment

#pragma mark - Class Methods

+ (void)updateFromMatch:(Match *)match success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [[self API] GET:[NSString stringWithFormat:@"championships/%@/matches/%@/comments", match.championship.rid, match.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self loadContent:responseObject inManagedObjectContext:self.editableManagedObjectContext usingCache:match.comments enumeratingObjectsWithBlock:^(Comment *comment, NSDictionary *contentEntry) {
                comment.match = match;
            } deletingUntouchedObjectsWithBlock:^(NSSet *untouchedObjects) {
                [self.editableManagedObjectContext deleteObjects:untouchedObjects];
            }];
            requestSucceedWithBlock(responseObject, success);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

+ (void)createCommentInMatch:(Match *)match withMessage:(NSString *)message success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [parameters setObject:message forKey:@"message"];
        NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName];
        [parameters setObject:[transformer transformedValue:[NSDate date]] forKey:@"date"];
        [[self API] POST:[NSString stringWithFormat:@"championships/%@/matches/%@/comments", match.championship.rid, match.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            Comment *comment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:FootblBackgroundManagedObjectContext()];
            comment.match = match;
            comment.rid = [responseObject objectForKey:kAPIIdentifierKey];
            [comment updateWithData:responseObject];
            SaveManagedObjectContext(FootblBackgroundManagedObjectContext());
            requestSucceedWithBlock(responseObject, success);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

#pragma mark - Instance Methods

- (void)updateWithData:(NSDictionary *)data {
    NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName];
    self.date = [transformer reverseTransformedValue:[data objectForKey:@"date"]];
    self.message = [data objectForKey:@"message"];
}

@end
