//
//  FootblModel.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/26/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "FootblModel.h"

@interface FootblModel ()

@end

#pragma mark FootblModel

@implementation FootblModel

#pragma mark - Class Methods

+ (FootblAPI *)API {
    return [FootblAPI sharedAPI];
}

+ (NSMutableDictionary *)generateDefaultParameters {
    return [[self API] generateDefaultParameters];
}

#pragma mark - Instance Methods

- (FootblAPI *)API {
    return [[self class] sharedAPI];
}

- (NSMutableDictionary *)generateDefaultParameters {
    return [[self class] generateDefaultParameters];
}

@end
