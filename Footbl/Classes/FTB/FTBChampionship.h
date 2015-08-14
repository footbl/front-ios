//
//  FTBChampionship.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/11/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBModel.h"

typedef NS_ENUM(NSUInteger, FTBChampionshipType) {
	FTBChampionshipTypeNationalLeague,
	FTBChampionshipTypeContinentalLeague,
	FTBChampionshipTypeWorldCup
};

@interface FTBChampionship : FTBModel

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *pictureURL;
@property (nonatomic, assign, readonly) FTBChampionshipType type;
@property (nonatomic, copy, readonly) NSString *country;

@end
