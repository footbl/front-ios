//
//  FTBuildType.h
//  Footbl
//
//  Created by Fernando Saragoca on 8/29/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FTBuildType) {
    FTBuildTypeUnknown = 0,
    FTBuildTypeDevelopment = 1,
    FTBuildTypeBeta = 2,
    FTBuildTypeAppStore = 3
};

extern FTBuildType FTGetBuildType();