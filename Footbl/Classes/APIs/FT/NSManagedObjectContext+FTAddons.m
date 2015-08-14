//
//  NSManagedObjectContext+FTAddons.m
//  Footbl
//
//  Created by Fernando Saragoça on 8/11/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <SPHipster/SPLog.h>
#import "NSManagedObjectContext+FTAddons.h"

#pragma mark NSManagedObjectContext (FTAddons)

@implementation NSManagedObjectContext (FTAddons)

#pragma mark - Instance Methods

- (void)deleteObjects:(NSSet *)objects {
    [objects enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [self deleteObject:obj];
    }];
}

- (void)performSave {
    NSError *error = nil;
    if (self.hasChanges && ![self save:&error]) {
        SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[error localizedFailureReason] userInfo:@{NSUnderlyingErrorKey: error}];
    }
}

@end
