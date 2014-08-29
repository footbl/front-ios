//
//  FTBuildType.m
//  Footbl
//
//  Created by Fernando Saragoca on 8/29/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "FTBuildType.h"

FTBuildType FTGetBuildType() {
    static FTBuildType buildType;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundleIdentifier = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
        if ([bundleIdentifier isEqualToString:@"com.madeatsampa.Footbl"]) {
            buildType = FTBuildTypeAppStore;
        } else if ([bundleIdentifier isEqualToString:@"com.madeatsampa.Footbl.development"]) {
            buildType = FTBuildTypeDevelopment;
        } else if ([bundleIdentifier isEqualToString:@"co.footbl.footbl1"]) {
            buildType = FTBuildTypeBeta;
        } else {
            buildType = FTBuildTypeUnknown;
        }
    });
    return buildType;
}