//
//  ChatHelper.m
//  Footbl
//
//  Created by Fernando Saragoca on 11/23/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "ChatHelper.h"
#import "Group.h"

@interface ChatHelper () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

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

- (instancetype)init {
    self = [super init];
    if (self) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"rid" ascending:YES]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"removed = %@", @NO];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[FTCoreDataStore mainQueueContext] sectionNameKeyPath:nil cacheName:nil];
        self.fetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![self.fetchedResultsController performFetch:&error]) {
            SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return self;
}

- (NSNumber *)unreadCount {
    NSNumber *unreadMessageCount = @0;
    for (Group *group in self.fetchedResultsController.fetchedObjects) {
        unreadMessageCount = @(unreadMessageCount.integerValue + group.unreadMessagesCountValue);
    }
    return unreadMessageCount;
}

- (void)fetchUnreadMessages {
    [self controllerDidChangeContent:self.fetchedResultsController];
    [Group getWithObject:nil success:^(id response) {
        [self controllerDidChangeContent:self.fetchedResultsController];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self controllerDidChangeContent:self.fetchedResultsController];
    }];
}

#pragma mark - Delegates & Data sources

#pragma mark - NSFetchedResultsController delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
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
