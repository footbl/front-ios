//
//  FTBTrophy.h
//  Footbl
//
//  Created by Leonardo Formaggio on 9/9/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBModel.h"

@interface FTBTrophy : FTBModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSNumber *progress;
@property (nonatomic, assign, getter=isProgressive) BOOL progressive;

@end
