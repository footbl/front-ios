//
//  ChatHelper.h
//  Footbl
//
//  Created by Fernando Saragoca on 11/23/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatHelper : NSObject

@property (strong, nonatomic) UITabBarItem *tabBarItem;

+ (instancetype)sharedHelper;
- (void)fetchUnreadMessages;
- (NSNumber *)unreadCount;

@end
