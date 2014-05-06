// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Championship.m instead.

#import "_Championship.h"

const struct ChampionshipAttributes ChampionshipAttributes = {
	.country = @"country",
	.currentRound = @"currentRound",
	.edition = @"edition",
	.name = @"name",
	.rounds = @"rounds",
};

const struct ChampionshipRelationships ChampionshipRelationships = {
	.competitors = @"competitors",
	.groups = @"groups",
	.matches = @"matches",
	.wallet = @"wallet",
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

	return keyPaths;
}




@dynamic country;






@dynamic currentRound;



- (int16_t)currentRoundValue {
	NSNumber *result = [self currentRound];
	return [result shortValue];
}

- (void)setCurrentRoundValue:(int16_t)value_ {
	[self setCurrentRound:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveCurrentRoundValue {
	NSNumber *result = [self primitiveCurrentRound];
	return [result shortValue];
}

- (void)setPrimitiveCurrentRoundValue:(int16_t)value_ {
	[self setPrimitiveCurrentRound:[NSNumber numberWithShort:value_]];
}





@dynamic edition;



- (int16_t)editionValue {
	NSNumber *result = [self edition];
	return [result shortValue];
}

- (void)setEditionValue:(int16_t)value_ {
	[self setEdition:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveEditionValue {
	NSNumber *result = [self primitiveEdition];
	return [result shortValue];
}

- (void)setPrimitiveEditionValue:(int16_t)value_ {
	[self setPrimitiveEdition:[NSNumber numberWithShort:value_]];
}





@dynamic name;






@dynamic rounds;



- (int16_t)roundsValue {
	NSNumber *result = [self rounds];
	return [result shortValue];
}

- (void)setRoundsValue:(int16_t)value_ {
	[self setRounds:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveRoundsValue {
	NSNumber *result = [self primitiveRounds];
	return [result shortValue];
}

- (void)setPrimitiveRoundsValue:(int16_t)value_ {
	[self setPrimitiveRounds:[NSNumber numberWithShort:value_]];
}





@dynamic competitors;

	
- (NSMutableSet*)competitorsSet {
	[self willAccessValueForKey:@"competitors"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"competitors"];
  
	[self didAccessValueForKey:@"competitors"];
	return result;
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
	

@dynamic wallet;

	






@end
