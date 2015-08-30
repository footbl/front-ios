//
//  FTBChampionship.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/11/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBModel.h"
#import "FTBConstants.h"

@interface FTBChampionship : FTBModel

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSURL *pictureURL;
@property (nonatomic, assign, readonly) FTBChampionshipType type;
@property (nonatomic, copy, readonly) NSString *country;
@property (nonatomic, copy, readonly) NSNumber *edition;
@property (nonatomic, assign, readonly, getter=isEnabled) BOOL enabled;

@end
