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

+ (NSDateFormatter *)dateFormatter {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
	dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
	return dateFormatter;
}

+ (NSValueTransformer *)dateJSONTransformer {
	return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
		return [self.dateFormatter dateFromString:dateString];
	} reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
		return [self.dateFormatter stringFromDate:date];
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
