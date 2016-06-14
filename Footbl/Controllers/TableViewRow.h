//
//  TableViewRow.h
//  Footbl
//
//  Created by Leonardo Formaggio on 4/3/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableViewRow : NSObject

@property (nonatomic, strong) Class resuseClass;
@property (nonatomic, copy) NSString *resuseIdentifier;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, copy) void (^setup)(__kindof UITableViewCell *, NSIndexPath *);
@property (nonatomic, copy) void (^selection)(NSIndexPath *);

- (instancetype)initWithClass:(Class)reuseClass;

@end
