//
//  NSNumber+Formatter.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/21/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "NSNumber+Formatter.h"

#pragma mark NSNumber (Formatter)

@implementation NSNumber (Formatter)

#pragma mark - Instance Methods

- (NSString *)shortStringValue {
    CGFloat number = self.floatValue;
    NSString *unit = @"";
    if (fabs(self.integerValue) >= 1000000) {
        number = (float)self.integerValue / 1000000.f;
        unit = NSLocalizedString(@"M", @"Unit for 1000000 (mega)");
    } else if (fabs(self.integerValue) >= 1000) {
        number = (float)self.integerValue / 1000.f;
        unit = NSLocalizedString(@"k", @"Unit for 1000 (kilo)");
    }
    
    if (number >= 10) {
        return [NSString stringWithFormat:@"%i%@", (int)number, unit];
    } else {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        formatter.formatterBehavior = [NSNumberFormatter defaultFormatterBehavior];
        formatter.maximumFractionDigits = 1;
        formatter.minimumFractionDigits = 0;
        return [NSString stringWithFormat:@"%@%@", [formatter stringFromNumber:@(number)], unit];
    }
    
    return @((int)number).stringValue;
}

- (NSString *)rankingStringValue {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.formatterBehavior = [NSNumberFormatter defaultFormatterBehavior];
    formatter.usesSignificantDigits = YES;
    formatter.usesGroupingSeparator = YES;
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.currencySymbol = @"#";
    return [formatter stringFromNumber:self];
}

- (NSString *)potStringValue {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.formatterBehavior = [NSNumberFormatter defaultFormatterBehavior];
    formatter.maximumFractionDigits = 2;
    formatter.minimumFractionDigits = 0;
    return [formatter stringFromNumber:self];
}

@end
