//
//  ChatHelper.m
//  Footbl
//
//  Created by Fernando Saragoca on 11/23/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "ChatHelper.h"

#import "FTBClient.h"
#import "FTBGroup.h"

@interface ChatHelper ()

@property (nonatomic, strong) NSMutableArray *groups;

@end

#pragma mark ChatHelper

@implementation ChatHelper

#pragma mark - Class Methods

+ (instancetype)sharedHelper {
    static ChatHelper *chatHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        chatHelper = [self new];
    });
    return chatHelper;
}

#pragma mark - Instance Methods

- (NSNumber *)unreadCount {
    NSNumber *unreadMessageCount = @0;
    for (FTBGroup *group in self.groups) {
        unreadMessageCount = @(unreadMessageCount.integerValue + group.unreadMessagesCount.integerValue);
    }
    return unreadMessageCount;
}

- (void)fetchUnreadMessages {
    [self controllerDidChangeContent];
	[[FTBClient client] groups:0 success:^(id object) {
        [self controllerDidChangeContent];
    } failure:^(NSError *error) {
        [self controllerDidChangeContent];
    }];
}

#pragma mark - Delegates & Data sources

#pragma mark - NSFetchedResultsController delegate

- (void)controllerDidChangeContent {
    NSNumber *unreadCount = self.unreadCount;
    if (unreadCount.integerValue == 0) {
        self.tabBarItem.badgeValue = nil;
    } else {
        self.tabBarItem.badgeValue = unreadCount.stringValue;
    }
    if (FBTweakValue(@"UX", @"Group", @"Chat badge (icon)", YES)) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadCount.integerValue];
    }
}

@end
