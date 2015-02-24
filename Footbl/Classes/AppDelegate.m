//
//  AppDelegate.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/25/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <AFNetworkActivityLogger/AFNetworkActivityLogger.h>
#import <Crashlytics/Crashlytics.h>
#import <FacebookSDK/FacebookSDK.h>
#import <FlurrySDK/Flurry.h>
#import <Tweaks/FBTweakShakeWindow.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#if FT_PREPARE_FOR_SCREENSHOTS
    #import <SimulatorStatusMagic/SDStatusBarManager.h>
#endif
#import <SPHipster/SPHipster.h>
#import <SPNotifier/SPNotifier.h>
#import "AppDelegate.h"
#import "ChatHelper.h"
#import "FriendsHelper.h"
#import "FootblTabBarController.h"
#import "Group.h"
#import "ImportImageHelper.h"
#import "LoadingHelper.h"
#import "Message.h"
#import "TutorialViewController.h"
#import "RatingHelper.h"
#import "SDImageCache+ShippedCache.h"

#import "Championship.h"
#import "FTOperationManager.h"
#import "FTAuthenticationManager.h"

#pragma mark AppDelegate

@implementation AppDelegate

#pragma mark - Getters/Setters

#pragma mark - Application Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#if FT_PREPARE_FOR_SCREENSHOTS
    [[SDStatusBarManager sharedInstance] enableOverrides];
#endif
    
    switch (SPGetBuildType()) {
        case SPBuildTypeDebug:
            kSPDebugLogLevel = SPDebugLogLevelInfo;
            [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
            [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelInfo];
            break;
        case SPBuildTypeAdHoc:
            kSPDebugLogLevel = SPDebugLogLevelInfo;
            SPLogSwitchToLocalFiles();
            [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
            [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelInfo];
            break;
        case SPBuildTypeAppStore:
            kSPDebugLogLevel = SPDebugLogLevelError;
            [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
            [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelOff];
            break;
        default:
            break;
    }

    SPLog(@"%@ (%@) v%@", SPGetApplicationName(), NSStringFromBuildType(SPGetBuildType()), SPGetApplicationVersion());
    
    [Crashlytics startWithAPIKey:@"ea711e6d0ffbc4e02fd2b6f82c766ce9a2458ec6"];
    [Flurry startSession:@"3TYX4BPG48MS9B89F2VB"];
    
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    
    [SPNotifier setToken:@"MtdSF5SsLWBLnhkjZa1nWF3ZXwg4ybGnuRzxi2sy"];
    [SPNotifier handleNotification:launchOptions];
    
    [[GAI sharedInstance] setDispatchInterval:20];
    [[GAI sharedInstance] setTrackUncaughtExceptions:YES];
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-43860362-8"];
    
    [[RatingHelper sharedInstance] run];
    
    static NSString *kVersionKey = @"kVersionKey";
    static NSString *kFirstRunKey = @"kFirstRunKey";
    BOOL newRelease = NO;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kVersionKey] && ![[[NSUserDefaults standardUserDefaults] objectForKey:kVersionKey] isEqualToString:SPGetApplicationVersion()]) {
        SPLog(@"Application updated from v%@ to v%@", [[NSUserDefaults standardUserDefaults] objectForKey:kVersionKey], SPGetApplicationVersion());
        newRelease = (SPGetBuildType() == SPBuildTypeAdHoc);
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kFirstRunKey] || newRelease) {
        [[FTAuthenticationManager sharedManager] logout];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPresentTutorialViewController];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFirstRunKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:SPGetApplicationVersion() forKey:kVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
#if FB_TWEAK_ENABLED == 1
    self.window = [[FBTweakShakeWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
#else
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
#endif
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    /*
    NSError *error = nil;
    [[SDImageCache sharedImageCache] importImagesFromPath:[[[NSBundle mainBundle] pathForResource:@"Cache" ofType:@""] stringByAppendingPathComponent:@"Images"] error:&error];
    if (error) {
        SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    */
    
    /* Import cached images
    [[SDImageCache sharedImageCache] downloadCachedImages];
    */
    
    self.footblTabBarController = [FootblTabBarController new];
    self.window.rootViewController = self.footblTabBarController;
    
    /*
    [[NSNotificationCenter defaultCenter] addObserverForName:FBSessionDidBecomeOpenActiveSessionNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [[FriendsHelper sharedInstance] getFbInvitableFriendsWithCompletionBlock:^(NSArray *friends, NSError *error) {
            if (error) {
                SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            } else {
                SPLogVerbose(@"%lu invitable friends", (unsigned long)friends.count);
            }
        }];
        [[FriendsHelper sharedInstance] reloadFriendsWithCompletionBlock:^(NSArray *friends, NSError *error) {
            if (error) {
                SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            } else {
                SPLogVerbose(@"%lu friends", (unsigned long)friends.count);
            }
        }];
        [[ImportImageHelper sharedInstance] importImageFromFacebookWithCompletionBlock:nil];
    }];
    
    [FBSession openActiveSessionWithReadPermissions:FB_READ_PERMISSIONS allowLoginUI:NO completionHandler:nil];
*/
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [ChatHelper sharedHelper].tabBarItem = self.footblTabBarController.tabBar.items.firstObject;
    [[ChatHelper sharedHelper] fetchUnreadMessages];
    [SPNotifier resetBadge];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
    [[FTCoreDataStore privateQueueContext] performSave];
    [[FTCoreDataStore mainQueueContext] performSave];

#if FT_PREPARE_FOR_SCREENSHOTS
    [[SDStatusBarManager sharedInstance] disableOverrides];
#endif
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    BOOL isAnonymous = [FTAuthenticationManager sharedManager].authenticationType == FTAuthenticationTypeAnonymous;
    NSArray *tags = @[isAnonymous ? @"Anonymous" : @"Authenticated"];
    switch (SPGetBuildType()) {
        case SPBuildTypeDebug:
        case SPBuildTypeAdHoc:
            [SPNotifier registerDeviceToken:deviceToken alias:[[UIDevice currentDevice] name] tags:tags success:nil failure:nil];
            break;
        case SPBuildTypeAppStore:
            [SPNotifier registerDeviceToken:deviceToken alias:nil tags:tags success:nil failure:nil];
            break;
        default:
            break;
    }
    
    NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [FTAuthenticationManager sharedManager].pushNotificationToken = token;
    SPLogVerbose(@"APNS: %@", token);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [SPNotifier handleNotification:userInfo];
    [Message handleRemoteNotification:userInfo];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([url.absoluteString rangeOfString:@"footbl://groups/"].location != NSNotFound) {
        NSString *groupCode = [url.absoluteString componentsSeparatedByString:@"/"].lastObject;
        if (groupCode.length > 0) {
            self.footblTabBarController.selectedIndex = 0;
            
            [[LoadingHelper sharedInstance] showHud];
            
            [Group joinGroupWithCode:groupCode success:^(id response) {
                [[LoadingHelper sharedInstance] hideHud];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [[LoadingHelper sharedInstance] hideHud];
                [[ErrorHandler sharedInstance] displayError:error];
            }];
            
            return YES;
        }
        
        return NO;
    }
    
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end