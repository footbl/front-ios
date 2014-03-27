//
//  Match.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/26/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <TransformerKit/TransformerKit.h>
#import "Championship.h"
#import "Match.h"
#import "Team.h"

@interface Match ()

@end

#pragma mark Match

@implementation Match

#pragma mark - Class Methods

+ (void)updateFromChampionship:(Championship *)championship success:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [[self API] GET:[NSString stringWithFormat:@"championships/%@/matches", championship.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self loadContent:responseObject inManagedObjectContext:FootblBackgroundManagedObjectContext() usingCache:nil enumeratingObjectsWithBlock:^(Match *object, NSDictionary *contentEntry) {
                object.championship = championship;
                SPLog(@"%@", object);
            } deletingUntouchedObjectsWithBlock:^(NSSet *untouchedObjects) {
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
    self.guest = [Team findOrCreateByIdentifier:[[data objectForKey:@"guest"] objectForKey:kAPIIdentifierKey] inManagedObjectContext:self.managedObjectContext];
    [self.guest updateWithData:[data objectForKey:@"guest"]];
    self.host = [Team findOrCreateByIdentifier:[[data objectForKey:@"host"] objectForKey:kAPIIdentifierKey] inManagedObjectContext:self.managedObjectContext];
    [self.host updateWithData:[data objectForKey:@"host"]];
    
    self.finished = [data objectForKey:@"finished"];
    self.hostScore = [[data objectForKey:@"result"] objectForKey:@"host"];
    self.guestScore = [[data objectForKey:@"result"] objectForKey:@"guest"];
    self.potDraw = [[data objectForKey:@"pot"] objectForKey:@"draw"];
    self.potGuest = [[data objectForKey:@"pot"] objectForKey:@"guest"];
    self.potHost = [[data objectForKey:@"pot"] objectForKey:@"host"];
    
    NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName];
    self.date = [transformer reverseTransformedValue:[data objectForKey:@"date"]];
}

- (void)updateWithSuccess:(FootblAPISuccessBlock)success failure:(FootblAPIFailureBlock)failure {
    [[self API] ensureAuthenticationWithSuccess:^{
        NSMutableDictionary *parameters = [self generateDefaultParameters];
        [[self API] GET:[NSString stringWithFormat:@"championships/%@/matches/%@", self.championship.rid, self.rid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            requestSucceedWithBlock(responseObject, success);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            requestFailedWithBlock(operation, parameters, error, failure);
        }];
    } failure:failure];
}

@end
