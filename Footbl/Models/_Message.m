// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Message.m instead.

#import "_Message.h"

const struct MessageAttributes MessageAttributes = {
	.deliveryFailed = @"deliveryFailed",
	.message = @"message",
	.typeString = @"typeString",
};

const struct MessageRelationships MessageRelationships = {
	.group = @"group",
	.user = @"user",
};

@implementation MessageID
@end

@implementation _Message

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Message";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Message" inManagedObjectContext:moc_];
}

- (MessageID*)objectID {
	return (MessageID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"deliveryFailedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"deliveryFailed"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic deliveryFailed;

- (BOOL)deliveryFailedValue {
	NSNumber *result = [self deliveryFailed];
	return [result boolValue];
}

- (void)setDeliveryFailedValue:(BOOL)value_ {
	[self setDeliveryFailed:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDeliveryFailedValue {
	NSNumber *result = [self primitiveDeliveryFailed];
	return [result boolValue];
}

- (void)setPrimitiveDeliveryFailedValue:(BOOL)value_ {
	[self setPrimitiveDeliveryFailed:[NSNumber numberWithBool:value_]];
}

@dynamic message;

@dynamic typeString;

@dynamic group;

@dynamic user;

@end

