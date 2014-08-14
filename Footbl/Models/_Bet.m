// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Bet.m instead.

#import "_Bet.h"

const struct BetAttributes BetAttributes = {
	.bid = @"bid",
	.result = @"result",
};

const struct BetRelationships BetRelationships = {
	.match = @"match",
	.user = @"user",
};

const struct BetFetchedProperties BetFetchedProperties = {
};

@implementation BetID
@end

@implementation _Bet

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Bet" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Bet";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Bet" inManagedObjectContext:moc_];
}

- (BetID*)objectID {
	return (BetID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"bidValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"bid"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"resultValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"result"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic bid;



- (int64_t)bidValue {
	NSNumber *result = [self bid];
	return [result longLongValue];
}

- (void)setBidValue:(int64_t)value_ {
	[self setBid:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveBidValue {
	NSNumber *result = [self primitiveBid];
	return [result longLongValue];
}

- (void)setPrimitiveBidValue:(int64_t)value_ {
	[self setPrimitiveBid:[NSNumber numberWithLongLong:value_]];
}





@dynamic result;



- (int64_t)resultValue {
	NSNumber *result = [self result];
	return [result longLongValue];
}

- (void)setResultValue:(int64_t)value_ {
	[self setResult:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveResultValue {
	NSNumber *result = [self primitiveResult];
	return [result longLongValue];
}

- (void)setPrimitiveResultValue:(int64_t)value_ {
	[self setPrimitiveResult:[NSNumber numberWithLongLong:value_]];
}





@dynamic match;

	

@dynamic user;

	






@end
