//
//  TableViewSection.m
//  Footbl
//
//  Created by Leonardo Formaggio on 4/3/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import "TableViewSection.h"

@interface TableViewSection ()

@property (nonatomic, strong) NSMutableArray *rows;

@end

@implementation TableViewSection

- (instancetype)init {
    self = [super init];
    if (self) {
        self.rows = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addRow:(TableViewRow *)row {
    [self.rows addObject:row];
}

- (void)insertRow:(TableViewRow *)row atIndex:(NSUInteger)index {
    [self.rows insertObject:row atIndex:index];
}

- (TableViewRow *)rowAtIndex:(NSUInteger)index {
    return self.rows[index];
}

- (NSUInteger)numberOfRows {
    return self.rows.count;
}

@end
