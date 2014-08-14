// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CreditRequest.m instead.

#import "_CreditRequest.h"

const struct CreditRequestAttributes CreditRequestAttributes = {
	.payed = @"payed",
	.value = @"value",
};

const struct CreditRequestRelationships CreditRequestRelationships = {
	.chargedUser = @"chargedUser",
	.creditedUser = @"creditedUser",
};

const struct CreditRequestFetchedProperties CreditRequestFetchedProperties = {
};

@implementation CreditRequestID
@end

@implementation _CreditRequest

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CreditRequest" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CreditRequest";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CreditRequest" inManagedObjectContext:moc_];
}

- (CreditRequestID*)objectID {
	return (CreditRequestID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"payedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"payed"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"valueValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"value"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic payed;



- (BOOL)payedValue {
	NSNumber *result = [self payed];
	return [result boolValue];
}

- (void)setPayedValue:(BOOL)value_ {
	[self setPayed:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitivePayedValue {
	NSNumber *result = [self primitivePayed];
	return [result boolValue];
}

- (void)setPrimitivePayedValue:(BOOL)value_ {
	[self setPrimitivePayed:[NSNumber numberWithBool:value_]];
}





@dynamic value;



- (int64_t)valueValue {
	NSNumber *result = [self value];
	return [result longLongValue];
}

- (void)setValueValue:(int64_t)value_ {
	[self setValue:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveValueValue {
	NSNumber *result = [self primitiveValue];
	return [result longLongValue];
}

- (void)setPrimitiveValueValue:(int64_t)value_ {
	[self setPrimitiveValue:[NSNumber numberWithLongLong:value_]];
}





@dynamic chargedUser;

	

@dynamic creditedUser;

	






@end
