//
//  FTBSeason.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBSeason.h"

@implementation FTBSeason

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	NSDictionary *keyPaths = @{@"sponsor": @"sponsor",
							   @"gift": @"gift",
							   @"finishAt": @"finishAt"};
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}

+ (NSValueTransformer *)finishAtJSONTransformer {
	return [super dateJSONTransformer];
}

- (NSInteger)daysToResetWallet {
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:[NSDate date] toDate:self.finishAt options:kNilOptions];
    return components.day;
}

// TODO: Remove lines below

- (NSString *)title {
    return @"42";
}

- (NSDate *)finishAt {
    return [[NSDate date] dateByAddingTimeInterval:2 * 24 * 60 * 60];
}

@end
