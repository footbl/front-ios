//
//  TransfersHelper.m
//  Footbl
//
//  Created by Fernando Saragoca on 11/24/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "CreditRequest.h"
#import "TransfersHelper.h"
#import "User.h"

@implementation TransfersHelper

#pragma mark - Class Methods

+ (void)fetchCountWithBlock:(void (^)(NSUInteger count))countBlock {
    if (!countBlock) {
        return;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CreditRequest"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"rid" ascending:YES]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"chargedUser.slug = %@ AND payed = %@", [User currentUser].slug, @NO];
    countBlock([[[FTCoreDataStore privateQueueContext] executeFetchRequest:fetchRequest error:nil] count]);
    
    [CreditRequest getWithObject:[User currentUser].editableObject success:^(id response) {
        countBlock([[response filteredArrayUsingPredicate:fetchRequest.predicate] count]);
    } failure:nil];
}

@end
