//
//  TableViewDataSource.h
//  Footbl
//
//  Created by Leonardo Formaggio on 4/3/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TableViewSection;

@interface TableViewDataSource : NSObject

- (void)addSection:(TableViewSection *)section;
- (void)insertSection:(TableViewSection *)section atIndex:(NSUInteger)index;
- (TableViewSection *)sectionAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfSections;

@end
