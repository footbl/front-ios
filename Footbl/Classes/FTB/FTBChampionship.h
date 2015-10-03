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

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSURL *pictureURL;
@property (nonatomic, assign) FTBChampionshipType type;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSNumber *edition;
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

@end
