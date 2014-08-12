// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Championship.m instead.

#import "_Championship.h"

const struct ChampionshipAttributes ChampionshipAttributes = {
	.active = @"active",
	.country = @"country",
	.currentRound = @"currentRound",
	.edition = @"edition",
	.name = @"name",
	.picture = @"picture",
	.rounds = @"rounds",
	.type = @"type",
	.year = @"year",
};

const struct ChampionshipRelationships ChampionshipRelationships = {
	.groups = @"groups",
	.matches = @"matches",
	.wallets = @"wallets",
};

const struct ChampionshipFetchedProperties ChampionshipFetchedProperties = {
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
	
	if ([key isEqualToString:@"activeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"active"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
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
	if ([key isEqualToString:@"roundsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rounds"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"yearValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"year"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic active;



- (BOOL)activeValue {
	NSNumber *result = [self active];
	return [result boolValue];
}

- (void)setActiveValue:(BOOL)value_ {
	[self setActive:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveActiveValue {
	NSNumber *result = [self primitiveActive];
	return [result boolValue];
}

- (void)setPrimitiveActiveValue:(BOOL)value_ {
	[self setPrimitiveActive:[NSNumber numberWithBool:value_]];
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






@dynamic year;



- (int64_t)yearValue {
	NSNumber *result = [self year];
	return [result longLongValue];
}

- (void)setYearValue:(int64_t)value_ {
	[self setYear:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveYearValue {
	NSNumber *result = [self primitiveYear];
	return [result longLongValue];
}

- (void)setPrimitiveYearValue:(int64_t)value_ {
	[self setPrimitiveYear:[NSNumber numberWithLongLong:value_]];
}





@dynamic groups;

	
- (NSMutableSet*)groupsSet {
	[self willAccessValueForKey:@"groups"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"groups"];
  
	[self didAccessValueForKey:@"groups"];
	return result;
}
	

@dynamic matches;

	
- (NSMutableSet*)matchesSet {
	[self willAccessValueForKey:@"matches"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"matches"];
  
	[self didAccessValueForKey:@"matches"];
	return result;
}
	

@dynamic wallets;

	
- (NSMutableSet*)walletsSet {
	[self willAccessValueForKey:@"wallets"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"wallets"];
  
	[self didAccessValueForKey:@"wallets"];
	return result;
}
	






@end
