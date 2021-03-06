//
//  RatingHelper.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/24/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <iRate/iRate.h>
#import <SPHipster/SPHipster.h>

#import "RatingHelper.h"
#import "FTBUser.h"

NSInteger const WalletReference = 105;

@interface RatingHelper () <iRateDelegate>

@end

#pragma mark RatingHelper

@implementation RatingHelper

#pragma mark - Class Methods

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Instance Methods

- (void)run {
    [iRate sharedInstance].appStoreID = APP_STORE_APP_ID;
    [iRate sharedInstance].applicationName = NSLocalizedString(@"Footbl", @"");
    [iRate sharedInstance].appStoreGenreID = 1000;
    [iRate sharedInstance].daysUntilPrompt = 2;
    [iRate sharedInstance].usesUntilPrompt = 3;
    [iRate sharedInstance].verboseLogging = (SPGetBuildType() != SPBuildTypeAppStore);
    [iRate sharedInstance].delegate = self;
}

- (void)showAlert {
    [[iRate sharedInstance] promptForRating];
}

#pragma mark - iRate Delegate

- (BOOL)iRateShouldPromptForRating {
	FTBUser *user = [FTBUser currentUser];
    if ((user.funds.integerValue + user.stake.integerValue) >= WalletReference && FT_ENABLE_REVIEW_ON_APP_STORE) {
        return YES;
    }
    return NO;
}

@end
