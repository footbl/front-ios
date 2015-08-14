//
//  SPBuild.h
//  SPHipster
//
//  Created by Fernando Saragoça on 1/12/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SPBuildType) {
    SPBuildTypeDebug,
    SPBuildTypeAdHoc,
    SPBuildTypeAppStore
};

extern NSString * NSStringFromBuildType(SPBuildType buildType);
extern NSString * SPGetApplicationName();
extern NSString * SPGetApplicationVersion();
extern SPBuildType SPGetBuildType();