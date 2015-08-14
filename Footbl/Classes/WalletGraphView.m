//
//  WalletGraphView.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/18/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "WalletGraphView.h"

@interface WalletGraphView ()

@end

#pragma mark WalletGraphView

@implementation WalletGraphView

#pragma mark - Getters/Setters

- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = [dataSource sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
    
    [self setNeedsDisplay];
}

#pragma mark - Instance Methods

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat margin = 23;
    CGFloat tinyMargin = 11;
    CGFloat columnHeight = CGRectGetHeight(rect);
    CGFloat maxValue = [[self.dataSource valueForKeyPath:@"@max.funds"] integerValue];
    NSInteger numberOfItems = MIN(MAX_HISTORY_COUNT, (int)self.dataSource.count);
    
    if (numberOfItems == 0) {
        return;
    }
    
    CGFloat columnWidth = (CGRectGetWidth(rect) - margin - margin - (tinyMargin * (numberOfItems - 1))) / numberOfItems;

    UIBezierPath *separator = [UIBezierPath bezierPathWithRect:CGRectMake(0, columnHeight - 0.5, CGRectGetWidth(rect), 0.5)];
    [[UIColor colorWithRed:0.83 green:0.85 blue:0.83 alpha:1] setFill];
    [separator fill];
    
    NSInteger displayIndex = 0;
    for (NSUInteger i = MAX(0, (int)self.dataSource.count - MAX_HISTORY_COUNT); i < self.dataSource.count; i++) {
        NSDictionary *value = self.dataSource[i];
        CGFloat wallet = [value[@"funds"] floatValue];
        CGFloat height = MIN(1, wallet / maxValue) * columnHeight;
        
        UIColor *graphColor = [UIColor colorWithRed:0.14 green:0.84 blue:0.36 alpha:1];
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(margin + (displayIndex * columnWidth) + (displayIndex * tinyMargin), columnHeight - height, columnWidth, height)];
        [graphColor setFill];
        [path fill];
        displayIndex ++;
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
