//
//  RatingHelper.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/24/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <iRate/iRate.h>
#import <SPHipster/SPHipster.h>
#import "RatingHelper.h"
#import "User.h"
#import "Wallet.h"

@interface RatingHelper () <iRateDelegate>

@end

#pragma mark RatingHelper

@implementation RatingHelper

#pragma mark - Class Methods

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

#pragma mark - Instance Methods

- (void)run {
    [iRate sharedInstance].appStoreID = APP_STORE_APP_ID;
    [iRate sharedInstance].applicationName = NSLocalizedString(@"Footbl", @"");
    [iRate sharedInstance].appStoreGenreID = 1000;
    [iRate sharedInstance].daysUntilPrompt = 5;
    [iRate sharedInstance].usesUntilPrompt = 10;
    [iRate sharedInstance].verboseLogging = (SPGetBuildType() != SPBuildTypeAppStore);
    [iRate sharedInstance].delegate = self;
}

- (void)showAlert {
    [[iRate sharedInstance] promptForRating];
}

#pragma mark - iRate Delegate

- (BOOL)iRateShouldPromptForRating {
    Wallet *wallet = [User currentUser].wallets.anyObject;
    if (wallet.fundsValue + wallet.stakeValue > 120 && FBTweakValue(@"UX", @"Footbl", @"Review on App Store", NO)) {
        return YES;
    }
    
    return NO;
}

@end
