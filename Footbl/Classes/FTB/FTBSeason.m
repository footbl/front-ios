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
                               @"startAt": @"startAt",
							   @"finishAt": @"finishAt"};
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}

+ (NSValueTransformer *)startAtJSONTransformer {
    return [super dateJSONTransformer];
}

+ (NSValueTransformer *)finishAtJSONTransformer {
	return [super dateJSONTransformer];
}

- (NSInteger)daysToResetWallet {
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:[NSDate date] toDate:self.finishAt options:kNilOptions];
    return components.day;
}

@end
