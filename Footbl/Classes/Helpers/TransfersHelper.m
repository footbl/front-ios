//
//  TransfersHelper.m
//  Footbl
//
//  Created by Fernando Saragoca on 11/24/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TransfersHelper.h"
#import "FTAuthenticationManager.h"

#import "FTBClient.h"
#import "FTBCreditRequest.h"
#import "FTBUser.h"

@implementation TransfersHelper

#pragma mark - Class Methods

+ (void)fetchCountWithBlock:(void (^)(NSUInteger count))countBlock {
    if (countBlock) {
		FTBUser *user = [FTBUser currentUser];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chargedUser == %@ AND payed == NO", user];
		[[FTBClient client] creditRequests:user chargedUser:nil page:0 success:^(id object) {
			countBlock([[object filteredArrayUsingPredicate:predicate] count]);
		} failure:nil];
    }
}

@end
