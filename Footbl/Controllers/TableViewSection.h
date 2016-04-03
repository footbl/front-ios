//
//  TableViewSection.h
//  Footbl
//
//  Created by Leonardo Formaggio on 4/3/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TableViewRow;

@interface TableViewSection : NSObject

@property (nonatomic, assign) CGFloat headerViewHeight;
@property (nonatomic, assign) CGFloat footerViewHeight;

- (void)addRow:(TableViewRow *)row;
- (void)insertRow:(TableViewRow *)row atIndex:(NSUInteger)index;
- (TableViewRow *)rowAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfRows;

@end
