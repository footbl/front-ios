//
//  TableViewDataSource.m
//  Footbl
//
//  Created by Leonardo Formaggio on 4/3/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import "TableViewDataSource.h"

@interface TableViewDataSource ()

@property (nonatomic, strong) NSMutableArray *sections;

@end

@implementation TableViewDataSource

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sections = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addSection:(TableViewSection *)section {
    [self.sections addObject:section];
}

- (void)insertSection:(TableViewSection *)section atIndex:(NSUInteger)index {
    [self.sections insertObject:section atIndex:index];
}

- (TableViewSection *)sectionAtIndex:(NSUInteger)index {
    return self.sections[index];
}

- (NSUInteger)numberOfSections {
    return self.sections.count;
}

@end
