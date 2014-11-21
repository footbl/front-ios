// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Prize.m instead.

#import "_Prize.h"

const struct PrizeAttributes PrizeAttributes = {
	.typeString = @"typeString",
	.value = @"value",
};

const struct PrizeRelationships PrizeRelationships = {
	.user = @"user",
};

@implementation PrizeID
@end

@implementation _Prize

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Prize" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Prize";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Prize" inManagedObjectContext:moc_];
}

- (PrizeID*)objectID {
	return (PrizeID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"valueValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"value"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic typeString;

@dynamic value;

- (float)valueValue {
	NSNumber *result = [self value];
	return [result floatValue];
}

- (void)setValueValue:(float)value_ {
	[self setValue:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveValueValue {
	NSNumber *result = [self primitiveValue];
	return [result floatValue];
}

- (void)setPrimitiveValueValue:(float)value_ {
	[self setPrimitiveValue:[NSNumber numberWithFloat:value_]];
}

@dynamic user;

@end

