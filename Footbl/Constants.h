//
//  Constants.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/27/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <Tweaks/FBTweak.h>
#import <Tweaks/FBTweakInline.h>
#import <Tweaks/FBTweakViewController.h>
#import "ErrorHandler.h"
#import "FootblAppearance.h"

#define APP_STORE_APP_ID @"881307076"

// Environment
#define FB_READ_PERMISSIONS @[@"public_profile", @"user_friends", @"email"]
#define FT_ENVIRONMENT_IS_PRODUCTION 1

// Updates
#define UPDATE_INTERVAL 60 * 3
#define UPDATE_INTERVAL_NEVER 60 * 60 * 24 * 365

// Groups
#define MAX_GROUP_NAME_SIZE 20