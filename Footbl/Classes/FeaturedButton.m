//
//  FeaturedButton.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/10/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "FeaturedButton.h"

#pragma mark FeaturedButton

@implementation FeaturedButton

#pragma mark - Instance Methods

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setImage:[UIImage imageNamed:@"featured_user"] forState:UIControlStateNormal];
        [self setTitle:NSLocalizedString(@"Featured users", @"") forState:UIControlStateNormal];
        [self setTitleColor:[UIColor ftGreenGrassColor] forState:UIControlStateNormal];
        [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        self.titleLabel.font = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:17];
        self.imageEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 80 - self.imageView.image.size.width, 0, 0);
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"goto"]];
        arrowImageView.center = CGPointMake(CGRectGetWidth(self.frame) - 20, CGRectGetMidY(self.frame));
        [self addSubview:arrowImageView];
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame) - 15, 0.5)];
        separatorView.backgroundColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.83 alpha:1];
        separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:separatorView];
    }
    return self;
}

@end
