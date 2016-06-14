//
//  TableViewRow.m
//  Footbl
//
//  Created by Leonardo Formaggio on 4/3/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import "TableViewRow.h"

@implementation TableViewRow

- (instancetype)initWithClass:(Class)reuseClass {
    self = [super init];
    if (self) {
        self.resuseClass = reuseClass;
        self.resuseIdentifier = NSStringFromClass(reuseClass);
    }
    return self;
}

@end
