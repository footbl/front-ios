//
//  TrophiesTableViewCell.m
//  Footbl
//
//  Created by Leonardo Formaggio on 6/11/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import "TrophiesTableViewCell.h"

@implementation TrophiesTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.placeholderLabel = [[UILabel alloc] init];
        self.placeholderLabel.textColor = [UIColor ftb_cellMatchBackgroundColor];
        self.placeholderLabel.font = [UIFont fontWithName:kFontNameMedium size:21];
        self.placeholderLabel.textAlignment = NSTextAlignmentCenter;
        self.placeholderLabel.text = NSLocalizedString(@"Trophy room still empty", nil);
        [self.contentView addSubview:self.placeholderLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.placeholderLabel.frame = self.bounds;
}

- (UIEdgeInsets)layoutMargins {
    return UIEdgeInsetsZero;
}

@end
