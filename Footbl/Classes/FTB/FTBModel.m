//
//  FTBModel.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/11/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBModel.h"

@implementation FTBModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{@"identifier": @"_id",
			 @"createdAt": @"createdAt",
			 @"updatedAt": @"updatedAt"};
}

+ (NSDateFormatter *)backendDateFormatter {
	static NSDateFormatter *backendDateFormatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		backendDateFormatter = [[NSDateFormatter alloc] init];
		backendDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
		backendDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
		backendDateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
	});
	return backendDateFormatter;
}

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        dateFormatter.AMSymbol = @"am";
        dateFormatter.PMSymbol = @"pm";
        dateFormatter.dateFormat = [@"EEEE, " stringByAppendingString:dateFormatter.dateFormat];
        dateFormatter.dateFormat = [dateFormatter.dateFormat stringByReplacingOccurrencesOfString:@", y" withString:@""];
        dateFormatter.dateFormat = [dateFormatter.dateFormat stringByReplacingOccurrencesOfString:@"/y" withString:@""];
        dateFormatter.dateFormat = [dateFormatter.dateFormat stringByReplacingOccurrencesOfString:@"y" withString:@""];
    });
    return dateFormatter;
}

+ (NSValueTransformer *)dateJSONTransformer {
	return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
		return [self.backendDateFormatter dateFromString:dateString];
	} reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
		return [self.backendDateFormatter stringFromDate:date];
	}];
}

+ (NSValueTransformer *)updatedAtJSONTransformer {
	return [self dateJSONTransformer];
}

+ (NSValueTransformer *)createdAtJSONTransformer {
	return [self dateJSONTransformer];
}

+ (instancetype)modelWithJSONDictionary:(NSDictionary *)dictionary {
	return [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:dictionary error:nil];
}

- (NSDictionary *)JSONDictionary {
	return [MTLJSONAdapter JSONDictionaryFromModel:self error:nil];
}

#pragma mark -

- (BOOL)isEqual:(FTBModel *)object {
	return [object isKindOfClass:[self class]] && [object.identifier isEqualToString:self.identifier];
}

- (NSUInteger)hash {
	return self.identifier.hash;
}

@end
