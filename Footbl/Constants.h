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
#import <SPHipster/SPHipster.h>
#import "ErrorHandler.h"
#import "FootblAppearance.h"

#define APP_STORE_APP_ID 881307076

// Environment
#define FB_READ_PERMISSIONS @[@"public_profile", @"user_friends", @"email"]
#define FT_ENVIRONMENT_IS_PRODUCTION 1
#define FT_API_PAGE_LIMIT 20

// Updates
#define UPDATE_INTERVAL 60 * 5
#define UPDATE_INTERVAL_NEVER 60 * 60 * 24 * 365

// Groups
#define MAX_GROUP_NAME_SIZE 20

// Users
#define MAX_FOLLOWERS_COUNT 20
#define MINIMUM_HISTORY_COUNT 3
#define MAX_HISTORY_COUNT 7

// Features
#define FT_ENABLE_MEDALS YES
#define FT_ENABLE_INFO_VIEW_REDESIGN YES
#define FT_ENABLE_PROFIT_NOTIFICATION YES
#define FT_ENABLE_HIGHLIGHT_ONLY_PROFIT YES
#define FT_ENABLE_REVIEW_ON_APP_STORE YES
#define FT_ENABLE_TAP_STATUS_BAR YES
#define FT_ENABLE_TAP_AND_HOLD YES
#define FT_ENABLE_SEARCH YES