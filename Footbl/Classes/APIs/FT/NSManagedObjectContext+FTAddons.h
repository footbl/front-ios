//
//  NSManagedObjectContext+FTAddons.h
//  Footbl
//
//  Created by Fernando Saragoça on 8/11/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (FTAddons)

- (void)deleteObjects:(NSSet *)objects;
- (void)performSave;

@end
