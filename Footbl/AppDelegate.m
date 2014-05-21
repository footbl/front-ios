//
//  AppDelegate.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/25/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import <FacebookSDK/FacebookSDK.h>
#import <SPHipster/SPHipster.h>
#import <SPNotifier/SPNotifier.h>
#import "AppDelegate.h"
#import "FriendsHelper.h"
#import "FootblAPI.h"
#import "FootblTabBarController.h"
#import "ImportImageHelper.h"
#import "TutorialViewController.h"
#import "SDImageCache+ShippedCache.h"

#pragma mark AppDelegate

@implementation AppDelegate

#pragma mark - Getters/Setters

@synthesize backgroundManagedObjectContext = _backgroundManagedObjectContext;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Application Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    switch (SPGetBuildType()) {
        case SPBuildTypeDebug:
            kSPDebugLogLevel = SPDebugLogLevelInfo;
            break;
        case SPBuildTypeAdHoc:
            kSPDebugLogLevel = SPDebugLogLevelInfo;
            SPLogSwitchToLocalFiles();
            break;
        case SPBuildTypeAppStore:
            kSPDebugLogLevel = SPDebugLogLevelError;
            break;
        default:
            break;
    }

    SPLog(@"%@ (%@) v%@", SPGetApplicationName(), NSStringFromBuildType(SPGetBuildType()), SPGetApplicationVersion());
    
    [Crashlytics startWithAPIKey:@"ea711e6d0ffbc4e02fd2b6f82c766ce9a2458ec6"];
    
    [SPNotifier setToken:@"MtdSF5SsLWBLnhkjZa1nWF3ZXwg4ybGnuRzxi2sy"];
    [SPNotifier handleNotification:launchOptions];
    
    static NSString *kVersionKey = @"kVersionKey";
    static NSString *kFirstRunKey = @"kFirstRunKey";
    BOOL newRelease = NO;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kVersionKey] && ![[[NSUserDefaults standardUserDefaults] objectForKey:kVersionKey] isEqualToString:SPGetApplicationVersion()]) {
        SPLog(@"Application updated from v%@ to v%@", [[NSUserDefaults standardUserDefaults] objectForKey:kVersionKey], SPGetApplicationVersion());
        newRelease = SPGetBuildType() != SPBuildTypeDebug;
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kFirstRunKey] || newRelease) {
        [[FootblAPI sharedAPI] logout];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPresentTutorialViewController];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFirstRunKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:SPGetApplicationVersion() forKey:kVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    NSError *error = nil;
    [[SDImageCache sharedImageCache] importImagesFromPath:[[[NSBundle mainBundle] pathForResource:@"Cache" ofType:@""] stringByAppendingPathComponent:@"Images"] error:&error];
    if (error) {
        SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    self.window.rootViewController = [FootblTabBarController new];
    
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
    [SPNotifier resetBadge];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    BOOL isAnonymous = [FootblAPI sharedAPI].authenticationType == FootblAuthenticationTypeAnonymous;
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
    SPLog(@"APNS: %@", deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [SPNotifier handleNotification:userInfo];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

- (void)saveBackgroundContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.backgroundManagedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the background managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)backgroundManagedObjectContext {
    if (_backgroundManagedObjectContext != nil) {
        return _backgroundManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _backgroundManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_backgroundManagedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        if (note.object != self.backgroundManagedObjectContext) {
            return;
        }
        
        SPLogVerbose(@"Merging context");
        
        [self.managedObjectContext performBlock:^{
            [self.managedObjectContext mergeChangesFromContextDidSaveNotification:note];
        }];
    }];
    
    return _backgroundManagedObjectContext;
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Footbl" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Footbl.sqlite"];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:nil]) {
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        
        NSError *error = nil;
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             
             Typical reasons for an error here include:
             * The persistent store is not accessible;
             * The schema for the persistent store is incompatible with current managed object model.
             Check the error message to determine what the actual problem was.
             
             
             If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
             
             If you encounter schema incompatibility errors during development, you can reduce their frequency by:
             * Simply deleting the existing store:
             [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
             
             * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
             @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
             
             Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
             
             */
            SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
