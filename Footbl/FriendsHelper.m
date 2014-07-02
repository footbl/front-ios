//
//  FriendsHelper.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/13/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <APAddressBook/APAddressBook.h>
#import <APAddressBook/APContact.h>
#import <FacebookSDK/FacebookSDK.h>
#import <SPHipster/SPHipster.h>
#import "FriendsHelper.h"
#import "User.h"

@interface FriendsHelper ()

@property (strong, nonatomic) NSMutableDictionary *cache;

@end

static CGFloat kCacheExpirationInterval = 60 * 5; // 5 minutes

#pragma mark FriendsHelper

@implementation FriendsHelper

#pragma mark - Class Methods

+ (instancetype)sharedInstance {
    static id _sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [self new];
    });
    return _sharedInstance;
}

#pragma mark - Getters/Setters

- (NSMutableDictionary *)cache {
    if (!_cache) {
        _cache = [NSMutableDictionary new];
    }
    return _cache;
}

#pragma mark - Instance Methods

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserverForName:kFootblAPINotificationAuthenticationChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            if (![[FootblAPI sharedAPI] isAuthenticated]) {
                [self.cache removeAllObjects];
            }
        }];
    }
    return self;
}

#pragma mark Footbl

- (void)reloadFriendsWithCompletionBlock:(void (^)(NSArray *friends, NSError *error))completionBlock {
    static NSString * kCacheKey = @"friends";
    [self getFbFriendsWithCompletionBlock:^(NSArray *fbFriends, NSError *error) {
        [self getContactsWithCompletionBlock:^(NSArray *contacts) {
            NSMutableArray *emails = [NSMutableArray new];
            for (NSArray *userEmails in [contacts valueForKeyPath:@"emails"]) {
                [emails addObjectsFromArray:userEmails];
            }
            if ([FootblAPI sharedAPI].isAuthenticated) {
                [User searchUsingEmails:emails usernames:nil ids:nil fbIds:[fbFriends valueForKeyPath:@"id"] success:^(NSArray *response) {
                    NSMutableArray *users = [NSMutableArray new];
                    [response enumerateObjectsUsingBlock:^(NSDictionary *user, NSUInteger idx, BOOL *stop) {
                        if (![user[kAPIIdentifierKey] isEqualToString:[User currentUser].rid]) {
                            if ([user[@"username"] length] > 0) {
                                [users addObject:user];
                            }
                        }
                    }];
                    self.cache[kCacheKey] = @{@"data" : users, @"updatedAt" : [NSDate date]};
                    if (completionBlock) completionBlock(users, nil);
                } failure:^(NSError *error) {
                    if (completionBlock) completionBlock(nil, error);
                }];
            } else {
                if (completionBlock) completionBlock(@[], nil);
            }
        }];
    }];
}

- (void)getFriendsWithCompletionBlock:(void (^)(NSArray *friends, NSError *error))completionBlock {
    static NSString * kCacheKey = @"friends";
    if (self.cache[kCacheKey] && [[NSDate date] timeIntervalSinceDate:self.cache[kCacheKey][@"updatedAt"]] < kCacheExpirationInterval) {
        if (completionBlock) completionBlock(self.cache[kCacheKey][@"data"], nil);
    } else {
        [self reloadFriendsWithCompletionBlock:completionBlock];
    }
}

#pragma mark Contacts

- (void)getContactsWithCompletionBlock:(void (^)(NSArray *contacts))completionBlock {
    if ([APAddressBook access] == APAddressBookAccessGranted) {
        APAddressBook *addressBook = [APAddressBook new];
        addressBook.fieldsMask = APContactFieldEmails | APContactFieldFirstName | APContactFieldLastName | APContactFieldThumbnail | APContactFieldCompositeName;
        addressBook.filterBlock = ^BOOL(APContact *contact) {
            return contact.emails.count > 0 && (contact.firstName.length > 0 || contact.lastName.length > 0);
        };
        addressBook.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES]];
        [addressBook loadContacts:^(NSArray *contacts, NSError *error) {
            if (completionBlock) completionBlock(contacts);
        }];
    } else {
        if (completionBlock) completionBlock(nil);
    }
}

#pragma mark Facebook

- (void)startRequestWithGraphPath:(NSString *)graphPath resultArray:(NSMutableArray *)resultArray completionBlock:(void (^)(id result, NSError *error))completionBlock {
    FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            completionBlock(nil, error);
        } else if (result[@"paging"][@"next"] && [result[@"data"] count] > 0) {
            NSString *nextPath = [@"me" stringByAppendingPathComponent:[result[@"paging"][@"next"] lastPathComponent]];
            [resultArray addObjectsFromArray:result[@"data"]];
            [self startRequestWithGraphPath:nextPath resultArray:resultArray completionBlock:completionBlock];
        } else {
            [resultArray addObjectsFromArray:result[@"data"]];
            if (completionBlock) completionBlock(resultArray, nil);
        }
    }];
}

- (void)startRequestWithGraphPath:(NSString *)graphPath completionBlock:(void (^)(id result, NSError *error))completionBlock {
    [self startRequestWithGraphPath:graphPath resultArray:[NSMutableArray new] completionBlock:completionBlock];
}

- (void)getFbFriendsWithCompletionBlock:(void (^)(NSArray *friends, NSError *error))completionBlock {
    static NSString * kCacheKey = @"fb_friends";
    if (self.cache[kCacheKey] && [[NSDate date] timeIntervalSinceDate:self.cache[kCacheKey][@"updatedAt"]] < kCacheExpirationInterval) {
        if (completionBlock) completionBlock(self.cache[kCacheKey][@"data"], nil);
        return;
    }
    
    [self startRequestWithGraphPath:@"me/friends?fields=name,last_name,first_name,picture.type(normal)" completionBlock:^(id result, NSError *error) {
        if (error) {
            if (completionBlock) completionBlock(nil, error);
            return;
        }
        self.cache[kCacheKey] = @{@"data" : result, @"updatedAt" : [NSDate date]};
        if (completionBlock) completionBlock(self.cache[kCacheKey][@"data"], nil);
    }];
}

- (void)getFbInvitableFriendsWithCompletionBlock:(void (^)(NSArray *friends, NSError *error))completionBlock {
    static NSString * kCacheKey = @"fb_invitable_friends";
    if (self.cache[kCacheKey] && [[NSDate date] timeIntervalSinceDate:self.cache[kCacheKey][@"updatedAt"]] < kCacheExpirationInterval) {
        if (completionBlock) completionBlock(self.cache[kCacheKey][@"data"], nil);
        return;
    }
    
    [self startRequestWithGraphPath:@"me/invitable_friends?fields=name,last_name,first_name,picture.type(normal)" completionBlock:^(id result, NSError *error) {
        if (error) {
            if (completionBlock) completionBlock(nil, error);
            return;
        }
        self.cache[kCacheKey] = @{@"data" : [result sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCompare:)]]], @"updatedAt" : [NSDate date]};
        if (completionBlock) completionBlock(self.cache[kCacheKey][@"data"], nil);
    }];
}

@end
