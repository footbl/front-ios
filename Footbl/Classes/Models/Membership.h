//
//  Membership.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/04/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "_Membership.h"

@interface Membership : _Membership

- (void)setNotificationsEnabled:(BOOL)enabled success:(FTOperationCompletionBlock)success failure:(FTOperationErrorBlock)failure;

@end
