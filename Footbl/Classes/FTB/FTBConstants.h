//
//  FTBConstants.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/22/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *const FTBBaseURL;
NSString *const FTBSignatureKey;

typedef void (^FTBBlockObject)(id object);
typedef void (^FTBBlockError)(NSError *error);

typedef NS_ENUM(NSUInteger, FTBChampionshipType) {
	FTBChampionshipTypeNationalLeague,
	FTBChampionshipTypeContinentalLeague,
	FTBChampionshipTypeWorldCup
};

typedef NS_ENUM(NSUInteger, FTBMatchResult) {
	FTBMatchResultDraw,
	FTBMatchResultGuest,
	FTBMatchResultHost
};

typedef NS_ENUM(NSInteger, FTBMatchStatus) {
	FTBMatchStatusWaiting,
	FTBMatchStatusLive,
	FTBMatchStatusFinished
};

typedef NS_ENUM(NSUInteger, FTBPrizeType) {
	FTBPrizeTypeDaily,
	FTBPrizeTypeUpdate
};

extern NSString * const kFTNotificationAPIOutdated;
extern NSString * const kFTNotificationAuthenticationChanged;
extern NSString * const kFTErrorDomain;

NSString *FTBISOCountryCodeForCountry(NSString *country);
