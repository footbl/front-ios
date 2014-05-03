// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Championship.m instead.

#import "_Championship.h"

const struct ChampionshipAttributes ChampionshipAttributes = {
	.country = @"country",
	.name = @"name",
	.year = @"year",
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
	
	if ([key isEqualToString:@"yearValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"year"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic country;






@dynamic name;






@dynamic year;



- (int16_t)yearValue {
	NSNumber *result = [self year];
	return [result shortValue];
}

- (void)setYearValue:(int16_t)value_ {
	[self setYear:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveYearValue {
	NSNumber *result = [self primitiveYear];
	return [result shortValue];
}

- (void)setPrimitiveYearValue:(int16_t)value_ {
	[self setPrimitiveYear:[NSNumber numberWithShort:value_]];
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
