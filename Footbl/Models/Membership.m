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
    return [[super enabledProperties] arrayByAddingObjectsFromArray:@[@"previousRanking", @"ranking"]];
}

+ (void)getWithObject:(Group *)group success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure {
    NSString *path = [self resourcePathWithObject:group];
    [[FTOperationManager sharedManager] GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[self class] loadContent:responseObject inManagedObjectContext:[[self class] editableManagedObjectContext] usingCache:group.members enumeratingObjectsWithBlock:^(Membership *membership, NSDictionary *data) {
            membership.group = group.editableObject;
        } untouchedObjectsBlock:^(NSSet *untouchedObjects) {
            [[self editableManagedObjectContext] deleteObjects:untouchedObjects];
        } completionBlock:success];
    } failure:failure];
}

#pragma mark - Instance Methods

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
