//
//  FTBTeam.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBModel.h"

@interface FTBTeam : FTBModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSURL *pictureURL;
@property (nonatomic, copy) NSURL *grayscalePictureURL;

@end
