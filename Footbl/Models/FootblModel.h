//
//  FootblModel.h
//  Footbl
//
//  Created by Fernando Saragoça on 3/26/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "_FootblModel.h"
#import "FootblAPI.h"

@interface FootblModel : _FootblModel

+ (FootblAPI *)API;
+ (NSMutableDictionary *)generateDefaultParameters;
- (FootblAPI *)API;
- (NSMutableDictionary *)generateDefaultParameters;

@end
