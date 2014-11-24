// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Championship.m instead.

#import "_Championship.h"

const struct ChampionshipAttributes ChampionshipAttributes = {
	.country = @"country",
	.currentRound = @"currentRound",
	.displayName = @"displayName",
	.edition = @"edition",
	.enabled = @"enabled",
	.name = @"name",
	.picture = @"picture",
	.rounds = @"rounds",
	.type = @"type",
};

const struct ChampionshipRelationships ChampionshipRelationships = {
	.entry = @"entry",
	.matches = @"matches",
};

@implementation ChampionshipID
@end

@implementation _Championship

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Championship" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Championship";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Championship" inManagedObjectContext:moc_];
}

- (ChampionshipID*)objectID {
	return (ChampionshipID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"currentRoundValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"currentRound"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"editionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"edition"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"enabledValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"enabled"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"roundsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rounds"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic country;

@dynamic currentRound;

- (int64_t)currentRoundValue {
	NSNumber *result = [self currentRound];
	return [result longLongValue];
}

- (void)setCurrentRoundValue:(int64_t)value_ {
	[self setCurrentRound:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveCurrentRoundValue {
	NSNumber *result = [self primitiveCurrentRound];
	return [result longLongValue];
}

- (void)setPrimitiveCurrentRoundValue:(int64_t)value_ {
	[self setPrimitiveCurrentRound:[NSNumber numberWithLongLong:value_]];
}

@dynamic displayName;

@dynamic edition;

- (int64_t)editionValue {
	NSNumber *result = [self edition];
	return [result longLongValue];
}

- (void)setEditionValue:(int64_t)value_ {
	[self setEdition:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveEditionValue {
	NSNumber *result = [self primitiveEdition];
	return [result longLongValue];
}

- (void)setPrimitiveEditionValue:(int64_t)value_ {
	[self setPrimitiveEdition:[NSNumber numberWithLongLong:value_]];
}

@dynamic enabled;

- (BOOL)enabledValue {
	NSNumber *result = [self enabled];
	return [result boolValue];
}

- (void)setEnabledValue:(BOOL)value_ {
	[self setEnabled:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveEnabledValue {
	NSNumber *result = [self primitiveEnabled];
	return [result boolValue];
}

- (void)setPrimitiveEnabledValue:(BOOL)value_ {
	[self setPrimitiveEnabled:[NSNumber numberWithBool:value_]];
}

@dynamic name;

@dynamic picture;

@dynamic rounds;

- (int64_t)roundsValue {
	NSNumber *result = [self rounds];
	return [result longLongValue];
}

- (void)setRoundsValue:(int64_t)value_ {
	[self setRounds:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveRoundsValue {
	NSNumber *result = [self primitiveRounds];
	return [result longLongValue];
}

- (void)setPrimitiveRoundsValue:(int64_t)value_ {
	[self setPrimitiveRounds:[NSNumber numberWithLongLong:value_]];
}

@dynamic type;

@dynamic entry;

@dynamic matches;

- (NSMutableSet*)matchesSet {
	[self willAccessValueForKey:@"matches"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"matches"];

	[self didAccessValueForKey:@"matches"];
	return result;
}

@end

