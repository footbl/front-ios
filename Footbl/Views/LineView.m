//
//  LineView.m
//  Footbl
//
//  Created by Leonardo Formaggio on 6/9/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import "LineView.h"
#import "UIView+Frame.h"

@interface LineView ()

@property (nonatomic, strong, readonly) NSLayoutConstraint *constraint;

@end

@implementation LineView

@synthesize attribute = _attribute;

- (NSInteger)attribute {
    if (_attribute == 0) {
        _attribute = NSLayoutAttributeHeight;
    }

    return _attribute;
}

- (NSLayoutConstraint *)constraint {
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstAttribute == self.attribute || constraint.secondAttribute == self.attribute) {
            return constraint;
        }
    }

    return nil;
}

- (void)resizeIfNeeded {
    self.constraint.constant = 1 / [UIScreen mainScreen].scale;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    [self resizeIfNeeded];
}

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];

    [self resizeIfNeeded];
}

@end
