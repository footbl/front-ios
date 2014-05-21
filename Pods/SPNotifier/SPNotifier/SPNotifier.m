//
//  SPNotifier.m
//  PortaDosFundos
//
//  Created by Fernando Saragoça on 22/04/13.
//  Copyright (c) 2013 Fernando Saragoça. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "SPNotifier.h"

#define BASE_URL @"http://notify.madeatsampa.com/api/v1"
#define ACTIVITY_URL @"http://notify-activity.madeatsampa.com/api/v1"
#define FRAMEWORK_VERSION @"0.1.2"
#define TOKEN_KEY @"notification_token_made_at_sampa"

static NSString * AFNormalizedDeviceTokenStringWithDeviceToken(id deviceToken) {
    return [[[[deviceToken description] uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

@interface SPNotifier ()

@end

#pragma mark SPNotifier

@implementation SPNotifier

#pragma mark - Getters/Setters

#pragma mark - Class Methods

+ (AFHTTPRequestOperationManager *)operationManager {
    static AFHTTPRequestOperationManager *_operationManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
        [[_operationManager requestSerializer] setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [_operationManager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    });

    return _operationManager;
}

+ (NSMutableArray *)sharedTags {
    NSMutableArray *tags = [NSMutableArray new];
    [tags addObject:[NSString stringWithFormat:@"v%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
    [tags addObject:[[UIDevice currentDevice] model]];
    [tags addObject:[NSString stringWithFormat:@"%@ %@", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]]];

    return tags;
}

+ (NSMutableDictionary *)sharedParameters {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"identifier"];
    [parameters setValue:[[UIDevice currentDevice] systemName] forKey:@"platform"];
    [parameters setValue:[[NSLocale currentLocale] identifier] forKey:@"locale"];
    [parameters setValue:[[NSLocale preferredLanguages] objectAtIndex:0] forKey:@"language"];
    [parameters setValue:[[NSTimeZone defaultTimeZone] name] forKey:@"timezone"];
    [parameters setValue:FRAMEWORK_VERSION forKey:@"framework_version"];
#ifdef DEBUG
    [parameters setValue:@"development" forKey:@"environment"];
    [parameters setValue:[[UIDevice currentDevice] name] forKey:@"alias"];
#else
    [parameters setValue:@"production" forKey:@"environment"];
    [parameters setValue:@"" forKey:@"alias"];
#endif

    return parameters;
}

+ (void)setToken:(NSString *)token {
    [[[self operationManager] requestSerializer] setValue:token forHTTPHeaderField:@"API_Key"];
}

+ (NSString *)token {
    return [[[[self operationManager] requestSerializer] HTTPRequestHeaders] objectForKey:@"API_Key"];
}

+ (void)resetBadge {
    if ([[UIApplication sharedApplication] applicationIconBadgeNumber] == 0) {
        return;
    }

    // Clear notifications from notification center
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:TOKEN_KEY];
    if (!deviceToken || [deviceToken length] == 0) {
        return;
    }

    NSString *urlString = [NSString stringWithFormat:@"%@/devices/%@/register_activity", ACTIVITY_URL, deviceToken];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request addValue:[self token] forHTTPHeaderField:@"token"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"PUT"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:nil failure:nil];
    [operation start];
}

+ (void)handleNotification:(NSDictionary *)notification {
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        return;
    }

    NSString *notificationID = @"";
    if ([notification objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] && [[notification objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] objectForKey:@"n_id"]) {
        notificationID = [[notification objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] objectForKey:@"n_id"];
    } else if ([notification objectForKey:@"n_id"]) {
        notificationID = [notification objectForKey:@"n_id"];
    } else {
        return;
    }

    NSString *urlString = [NSString stringWithFormat:@"%@/notifications/%@/view", ACTIVITY_URL, notificationID];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request addValue:[self token] forHTTPHeaderField:@"API_Key"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"PUT"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:nil failure:nil];
    [operation start];

    urlString = nil;
    if ([notification objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] && [[notification objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] objectForKey:@"url"]) {
        urlString = [[notification objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] objectForKey:@"url"];
    } else if ([notification objectForKey:@"url"]) {
        urlString = [notification objectForKey:@"url"];
    } else {
        return;
    }

    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive && urlString) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
}

+ (void)registerDeviceToken:(NSString *)deviceToken withPayload:(NSDictionary *)payload success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    [[NSUserDefaults standardUserDefaults] setValue:AFNormalizedDeviceTokenStringWithDeviceToken(deviceToken) forKey:TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [[self operationManager] PUT:[NSString stringWithFormat:@"devices/%@", AFNormalizedDeviceTokenStringWithDeviceToken(deviceToken)] parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) failure(error);
    }];
}

+ (void)registerDeviceToken:(id)deviceToken {
    NSMutableDictionary *mutablePayload = [self sharedParameters];

    [mutablePayload setValue:[self sharedTags] forKey:@"tags"];

    [self registerDeviceToken:deviceToken withPayload:mutablePayload success:nil failure:nil];
}

+ (void)registerDeviceToken:(id)deviceToken alias:(NSString *)alias tags:(NSArray *)tags success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *mutablePayload = [self sharedParameters];

    NSMutableArray *tagsArray = [self sharedTags];
    if (tags) {
        [tagsArray addObjectsFromArray:tags];
    }
    [mutablePayload setValue:tagsArray forKey:@"tags"];

    if (alias) {
        [mutablePayload setValue:alias forKey:@"alias"];
    }

    [self registerDeviceToken:deviceToken withPayload:mutablePayload success:success failure:failure];
}

+ (void)unregisterDeviceToken:(NSString *)deviceToken success:(void (^)())success failure:(void (^)(NSError *error))failure {
    [[self operationManager] DELETE:[NSString stringWithFormat:@"devices/%@", AFNormalizedDeviceTokenStringWithDeviceToken(deviceToken)] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) failure(error);
    }];
}

@end
