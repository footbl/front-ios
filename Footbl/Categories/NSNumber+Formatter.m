//
//  NSNumber+Formatter.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/21/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "NSNumber+Formatter.h"

static CGFloat kMaxValueToShortTextFormat = 999999;

#pragma mark NSNumber (Formatter)

@implementation NSNumber (Formatter)

#pragma mark - Instance Methods

- (NSString *)walletStringValue {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.formatterBehavior = [NSNumberFormatter defaultFormatterBehavior];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    return [formatter stringFromNumber:self];
}

- (NSString *)limitedWalletStringValue {
    if (self.integerValue > kMaxValueToShortTextFormat) {
        return self.shortStringValue;
    } else {
        return self.walletStringValue;
    }
}

- (NSString *)shortStringValue {
    CGFloat number = self.floatValue;
    NSString *unit = @"";
    if (fabs(self.floatValue) >= 1000000) {
        number = (float)self.integerValue / 1000000.f;
        unit = NSLocalizedString(@"M", @"Unit for 1000000 (mega)");
    } else if (fabs(self.floatValue) >= 1000) {
        number = (float)self.integerValue / 1000.f;
        unit = NSLocalizedString(@"k", @"Unit for 1000 (kilo)");
    }
    
    if (number >= 10) {
        return [NSString stringWithFormat:@"%i%@", (int)number, unit];
    } else {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.formatterBehavior = [NSNumberFormatter defaultFormatterBehavior];
        formatter.maximumFractionDigits = 1;
        formatter.minimumFractionDigits = 0;
        return [NSString stringWithFormat:@"%@%@", [formatter stringFromNumber:@(number)], unit];
    }
    
    return @((int)number).stringValue;
}

- (NSString *)rankingStringValue {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.formatterBehavior = [NSNumberFormatter defaultFormatterBehavior];
    formatter.usesSignificantDigits = YES;
    formatter.usesGroupingSeparator = YES;
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.currencySymbol = @"#";
    if (FBTweakValue(@"Values", @"Profile", @"Ranking", 0, 0, HUGE_VAL)) {
        return [formatter stringFromNumber:@(FBTweakValue(@"Values", @"Profile", @"Ranking", 0, 0, HUGE_VAL))];
    } else {
        return [formatter stringFromNumber:self];
    }
}

- (NSString *)potStringValue {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.formatterBehavior = [NSNumberFormatter defaultFormatterBehavior];
    formatter.maximumFractionDigits = 2;
    formatter.minimumFractionDigits = 2;
    return [formatter stringFromNumber:self];
}

@end
