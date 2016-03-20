//
//  FriendsHelper.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/13/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <APAddressBook/APAddressBook.h>
#import <APAddressBook/APContact.h>
#import <FacebookSDK/FacebookSDK.h>
#import <SPHipster/SPHipster.h>
#import "FriendsHelper.h"

#import "FTBClient.h"
#import "FTBUser.h"

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
        [[NSNotificationCenter defaultCenter] addObserverForName:kFTNotificationAuthenticationChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            if (![[FTBClient client] isAuthenticated]) {
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
            if ([[FTBClient client] isAuthenticated]) {
                __block NSInteger operationsCount = 0;
                __block NSMutableArray *searchResults = [NSMutableArray new];
				__block NSMutableSet *resultSet = [NSMutableSet new];
				__block NSMutableArray *result = [NSMutableArray new];
				
                void(^finishedBlock)(id response) = ^(id response) {
                    operationsCount--;
                    if (response && [response isKindOfClass:[NSArray class]]) {
                        [searchResults addObjectsFromArray:response];
                    }
                    
                    if (operationsCount == 0) {
						FTBUser *me = [FTBUser currentUser];
                        for (NSDictionary *user in searchResults) {
							NSString *identifier = user[@"identifier"];
                            if (![resultSet containsObject:identifier] && ![identifier isEqualToString:me.identifier]) {
                                [resultSet addObject:identifier];
                                [result addObject:user];
                            }
                        }
                        [result sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
                        self.cache[kCacheKey] = @{@"data" : result, @"updatedAt" : [NSDate date]};
                        if (completionBlock) completionBlock(result, nil);
                    }
                };
				
				if (contacts) {
					NSArray *emails = [contacts valueForKeyPath:@"emails"];
					for (int i = 0; i < emails.count; i += 100) {
						operationsCount++;
						NSArray *range = [emails objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(i, MIN(emails.count - i, 100))]];
						[[FTBClient client] usersWithEmails:range facebookIds:nil usernames:nil name:nil page:0 success:^(id object) {
							finishedBlock(object);
						} failure:^(NSError *error) {
							SPLogError(@"%@", error);
							finishedBlock(@[]);
						}];
					}
				}
				
                if (fbFriends) {
					NSArray *fbIds = [fbFriends valueForKeyPath:@"id"];
                    for (int i = 0; i < fbIds.count; i += 100) {
                        operationsCount++;
                        NSArray *range = [fbIds objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(i, MIN(fbIds.count - i, 100))]];
						[[FTBClient client] usersWithEmails:nil facebookIds:range usernames:nil name:nil page:0 success:^(id object) {
                            finishedBlock(object);
                        } failure:^(NSError *error) {
                            SPLogError(@"%@", error);
                            finishedBlock(@[]);
                        }];
                    }
                }
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
        addressBook.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
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
    
    [self startRequestWithGraphPath:@"me/friends?fields=name,picture.type(normal)" completionBlock:^(id result, NSError *error) {
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
        self.cache[kCacheKey] = @{@"data" : [result sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]], @"updatedAt" : [NSDate date]};
        if (completionBlock) completionBlock(self.cache[kCacheKey][@"data"], nil);
    }];
}


- (void)searchFriendsWithQuery:(NSString *)searchText completionBlock:(void (^)(NSArray *friends, NSError *error))completionBlock {
    return [self searchFriendsWithQuery:searchText existingUsers:nil completionBlock:completionBlock];
}

- (void)searchFriendsWithQuery:(NSString *)searchText existingUsers:(NSSet *)users completionBlock:(void (^)(NSArray *friends, NSError *error))completionBlock {
    NSString *trimmedSearchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	FTBUser *me = [FTBUser currentUser];
    
    __block NSMutableArray *searchResults = [NSMutableArray new];
    void(^finishedBlock)(id response) = ^(id response) {
        if (response && [response isKindOfClass:[NSArray class]]) {
            [searchResults addObjectsFromArray:response];
        }
        
        NSMutableSet *resultSet = [NSMutableSet new];
        NSMutableArray *result = [NSMutableArray new];
        for (FTBUser *user in searchResults) {
            // Checks against being the own user, user already in the array and user already in the existing users passed in
            if (![resultSet containsObject:user.identifier] && ![user.identifier isEqualToString:me.identifier] && ![users containsObject:user.identifier]) {
                [resultSet addObject:user.identifier];
                [result addObject:user];
            }
        }
        [result sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
        if (completionBlock) completionBlock(result, nil);
    };
    
	[[FTBClient client] usersWithEmails:@[trimmedSearchText] facebookIds:nil usernames:@[trimmedSearchText] name:@[trimmedSearchText] page:0 success:^(id object) {
        finishedBlock(object);
    } failure:^(NSError *error) {
        SPLogError(@"%@", error);
        finishedBlock(@[]);
    }];
}

@end
