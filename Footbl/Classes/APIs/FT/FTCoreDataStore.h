//
//  FTCoreDataStore.h
//  Footbl
//
//  Created by Fernando Saragoça on 8/27/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTCoreDataStore : NSObject

+ (instancetype)defaultStore;
+ (NSManagedObjectContext *)mainQueueContext;
+ (NSManagedObjectContext *)privateQueueContext;

@end
