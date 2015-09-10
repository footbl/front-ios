//
//  FTBTrophy.h
//  Footbl
//
//  Created by Leonardo Formaggio on 9/9/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBModel.h"

@interface FTBTrophy : FTBModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign, getter=isProgressive) BOOL progressive;
@property (nonatomic, assign) NSNumber *progress;

- (NSString *)imageName;

@end
