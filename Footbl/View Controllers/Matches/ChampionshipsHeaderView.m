//
//  ChampionshipsHeaderView.m
//  Footbl
//
//  Created by Leonardo Formaggio on 5/1/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import "ChampionshipsHeaderView.h"
#import "UIView+Frame.h"

@implementation ChampionshipsHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ftb_navigationBarColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        self.headerLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.headerLabel.font = [UIFont fontWithName:kFontNameMedium size:12];
        self.headerLabel.textColor = [UIColor colorWithRed:0.00/255.f green:169/255.f blue:72./255.f alpha:1.00];
        self.headerLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.headerLabel];
        
        self.headerSliderBackImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider_tab_back"]];
        self.headerSliderBackImageView.center = CGPointMake(15, self.headerLabel.midY);
        self.headerSliderBackImageView.hidden = YES;
        [self addSubview:self.headerSliderBackImageView];
        
        self.headerSliderForwardImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider_tab_forward"]];
        self.headerSliderForwardImageView.center = CGPointMake(self.width - 15, self.headerLabel.midY);
        self.headerSliderForwardImageView.hidden = YES;
        [self addSubview:self.headerSliderForwardImageView];
        
        UIView *bottomSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 0.5, self.width, 0.5)];
        bottomSeparatorView.backgroundColor = [UIColor ftb_navigationBarSeparatorColor];
        bottomSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:bottomSeparatorView];
        
        UIView *topSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0.5)];
        topSeparatorView.backgroundColor = [UIColor ftb_navigationBarSeparatorColor];
        topSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:topSeparatorView];
    }
    return self;
}

@end
