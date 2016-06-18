//
//  WalletHighestTableViewCell.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/20/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "WalletHighestTableViewCell.h"
#import "NSNumber+Formatter.h"

@interface WalletHighestTableViewCell ()

@property (strong, nonatomic) UILabel *walletLabel;

@end

#pragma mark WalletHighestTableViewCell

@implementation WalletHighestTableViewCell

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.walletLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        self.walletLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.walletLabel];
    }
    return self;
}

- (void)setHighestValue:(NSNumber *)highestValue withDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = [NSString stringWithFormat:NSLocalizedString(@"'Highest: %@ in' MMMM YYYY", @"Highest: {highest funds} in {month format} {year format}"), highestValue.walletStringValue];
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    attributes[NSForegroundColorAttributeName] = [UIColor colorWithRed:141/255.f green:151/255.f blue:144/255.f alpha:1.00];
    attributes[NSFontAttributeName] = [UIFont fontWithName:kFontNameAvenirNextMedium size:12];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
    [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:[formatter stringFromDate:date] attributes:attributes]];
    attributes[NSForegroundColorAttributeName] = [UIColor ftb_greenMoneyColor];
    NSRange range = [attributedText.string rangeOfString:[NSLocalizedString(@"$", @"") stringByAppendingString:highestValue.walletStringValue]];
    if (range.location == NSNotFound) {
        range = [attributedText.string rangeOfString:highestValue.walletStringValue];
    }
    [attributedText setAttributes:attributes range:range];
    self.walletLabel.attributedText = attributedText;
}

@end
