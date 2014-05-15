//
//  User.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/04/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "User.h"

@interface User ()

@end

#pragma mark User

@implementation User

#pragma mark - Class Methods

+ (instancetype)currentUser {
    return [[self API] currentUser];
}

+ (void)searchUsingEmails:(NSArray *)emails usernames:(NSArray *)usernames ids:(NSArray *)ids fbIds:(NSArray *)fbIds success:(FootblAPISuccessWithResponseBlock)success failure:(FootblAPIFailureBlock)failure {
    NSString *key = [NSString stringWithFormat:@"%lu%lu%lu%lu%@", (unsigned long)emails.hash, (unsigned long)usernames.hash, (unsigned long)ids.hash, (unsigned long)fbIds.hash, API_DICTIONARY_KEY];
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateParametersWithPage:API_CURRENT_PAGE(key)];
        if (emails) {
            parameters[@"emails"] = emails;
        }
        if (usernames) {
            parameters[@"usernames"] = usernames;
        }
        if (ids) {
            parameters[@"ids"] = ids;
        }
        if (fbIds) {
            parameters[@"facebookIds"] = fbIds;
        }
        
        [[self API] GET:@"users" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            API_APPEND_RESULT(responseObject, key);
            if ([responseObject count] == [self responseLimit]) {
                API_APPEND_PAGE(key);
                [self searchUsingEmails:emails usernames:usernames ids:ids fbIds:fbIds success:success failure:failure];
            } else {
                requestSucceedWithBlock(operation, parameters, nil);
                if (success) success(API_RESULT(key));
                API_RESET_KEY(key);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
            API_RESET_KEY(key);
        }];
    } failure:failure];
}

#pragma mark - Instance Methods

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
    
    self.verified = data[@"verified"];
    self.email = data[@"email"];
    self.username = data[@"username"];
}

@end
