//
//  SPNotifier.h
//  PortaDosFundos
//
//  Created by Fernando Saragoça on 22/04/13.
//  Copyright (c) 2013 Fernando Saragoça. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPNotifier : NSObject

+ (void)setToken:(NSString *)token;
+ (void)resetBadge;
+ (void)registerDeviceToken:(id)deviceToken;
+ (void)registerDeviceToken:(id)deviceToken alias:(NSString *)alias tags:(NSArray *)tags success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
+ (void)handleNotification:(NSDictionary *)notification;
+ (void)unregisterDeviceToken:(id)deviceToken success:(void (^)())success failure:(void (^)(NSError *error))failure;

@end
