// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Bet.m instead.

#import "_Bet.h"

const struct BetAttributes BetAttributes = {
	.date = @"date",
	.finished = @"finished",
	.result = @"result",
	.reward = @"reward",
	.toReturn = @"toReturn",
	.value = @"value",
};

const struct BetRelationships BetRelationships = {
	.match = @"match",
	.wallet = @"wallet",
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
	
	if ([key isEqualToString:@"finishedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"finished"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"resultValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"result"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"rewardValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"reward"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"toReturnValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"toReturn"];
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




@dynamic date;






@dynamic finished;



- (BOOL)finishedValue {
	NSNumber *result = [self finished];
	return [result boolValue];
}

- (void)setFinishedValue:(BOOL)value_ {
	[self setFinished:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveFinishedValue {
	NSNumber *result = [self primitiveFinished];
	return [result boolValue];
}

- (void)setPrimitiveFinishedValue:(BOOL)value_ {
	[self setPrimitiveFinished:[NSNumber numberWithBool:value_]];
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





@dynamic reward;



- (float)rewardValue {
	NSNumber *result = [self reward];
	return [result floatValue];
}

- (void)setRewardValue:(float)value_ {
	[self setReward:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveRewardValue {
	NSNumber *result = [self primitiveReward];
	return [result floatValue];
}

- (void)setPrimitiveRewardValue:(float)value_ {
	[self setPrimitiveReward:[NSNumber numberWithFloat:value_]];
}





@dynamic toReturn;



- (float)toReturnValue {
	NSNumber *result = [self toReturn];
	return [result floatValue];
}

- (void)setToReturnValue:(float)value_ {
	[self setToReturn:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveToReturnValue {
	NSNumber *result = [self primitiveToReturn];
	return [result floatValue];
}

- (void)setPrimitiveToReturnValue:(float)value_ {
	[self setPrimitiveToReturn:[NSNumber numberWithFloat:value_]];
}





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





@dynamic match;

	

@dynamic wallet;

	






@end
