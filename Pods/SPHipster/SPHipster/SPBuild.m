//
//  SPBuild.m
//  SPHipster
//
//  Created by Fernando Saragoça on 1/12/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "SPBuild.h"

#pragma mark SPBuild

#pragma mark - Extern Functions

NSString * NSStringFromBuildType(SPBuildType buildType) {
    switch (buildType) {
            case SPBuildTypeAdHoc:      return @"AdHoc";
            case SPBuildTypeAppStore:   return @"App Store";
            case SPBuildTypeDebug:      return @"Debug";
    }
}

NSString * SPGetApplicationName() {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
}

NSString * SPGetApplicationVersion() {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSString *shortVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (![version isEqualToString:shortVersion]) {
        version = [NSString stringWithFormat:@"%@ (%@)", shortVersion, version];
    }
    return version;
}

// Based on this awesome gist from @steipete https://gist.github.com/steipete/7668246
SPBuildType SPGetBuildType() {
#if TARGET_IPHONE_SIMULATOR
    return SPBuildTypeDebug;
#else
    static BOOL isDevelopment = NO;
    static BOOL isAppStore = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // There is no provisioning profile in AppStore Apps.
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"]];
        if (data) {
            const char *bytes = [data bytes];
            NSMutableString *profile = [[NSMutableString alloc] initWithCapacity:data.length];
            for (NSUInteger i = 0; i < data.length; i++) {
                [profile appendFormat:@"%c", bytes[i]];
            }
            // Look for debug value, if detected we're a development build.
            NSString *cleared = [[profile componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];
            isDevelopment = [cleared rangeOfString:@"<key>get-task-allow</key><true/>"].length > 0;
        } else {
            isAppStore = YES;
        }
    });
    if (isAppStore) {
        return SPBuildTypeAppStore;
    } else if (isDevelopment) {
        return SPBuildTypeDebug;
    } else {
        return SPBuildTypeAdHoc;
    }
#endif
}
