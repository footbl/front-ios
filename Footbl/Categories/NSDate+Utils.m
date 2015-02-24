//
//  NSDate+Utils.m
//  Footbl
//
//  Created by Fernando Saragoca on 11/23/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "NSDate+Utils.h"

#pragma mark NSDate (Utils)

@implementation NSDate (Utils)

static const unsigned componentFlags = (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit);

#pragma mark - Class Methods

+ (NSCalendar *)currentCalendar {
    static NSCalendar *sharedCalendar = nil;
    if (!sharedCalendar) {
        sharedCalendar = [NSCalendar autoupdatingCurrentCalendar];
    }
    return sharedCalendar;
}

#pragma mark - Instance Methods

- (BOOL)isEqualToDateIgnoringTime:(NSDate *)date {
    NSDateComponents *components1 = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    NSDateComponents *components2 = [[NSDate currentCalendar] components:componentFlags fromDate:date];
    return ((components1.year == components2.year) && (components1.month == components2.month) && (components1.day == components2.day));
}

- (BOOL)isToday {
    return [self isEqualToDateIgnoringTime:[NSDate date]];
}

@end
