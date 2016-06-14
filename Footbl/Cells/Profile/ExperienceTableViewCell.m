//
//  ExperienceTableViewCell.m
//  Footbl
//
//  Created by Leonardo Formaggio on 6/11/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import "ExperienceTableViewCell.h"
#import "UIView+Frame.h"
#import "FootblAppearance.h"

@interface LDProgressView (Footbl)

@property (nonatomic, copy, readonly) NSString *progressTextOverride;

@end

@implementation LDProgressView (Footbl)

@dynamic progressTextOverride;

- (void)drawRightAlignedLabelInRect:(CGRect)rect {
    if (rect.size.width > 40) {
        UILabel *label = [[UILabel alloc] initWithFrame:rect];
        label.adjustsFontSizeToFitWidth = YES;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentRight;
        label.text = self.progressTextOverride ? self.progressTextOverride : [NSString stringWithFormat:@"%.0f%%", self.progress*100];
        label.font = [UIFont fontWithName:kFontNameBlack size:10];
        label.textColor = [UIColor whiteColor];
        [label drawTextInRect:CGRectMake(rect.origin.x + 6, rect.origin.y, rect.size.width-12, rect.size.height+1)];
    }
}

@end

@implementation ExperienceTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.progressView = [[LDProgressView alloc] init];
        self.progressView.color = [UIColor ftb_greenMoneyColor];
        self.progressView.background = [UIColor ftb_cellMatchBackgroundColor];
        self.progressView.showBackgroundInnerShadow = @NO;
        self.progressView.flat = @YES;
        self.progressView.showStroke = @NO;
        self.progressView.animate = @NO;
        self.progressView.type = LDProgressSolid;
        [self.progressView overrideProgressText:@"120 XP"];
        [self.contentView addSubview:self.progressView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.progressView.width = self.width - 40;
    self.progressView.height = 20;
    self.progressView.midY = self.height / 2;
    self.progressView.x = 20;
}

- (UIEdgeInsets)layoutMargins {
    return UIEdgeInsetsZero;
}

@end
