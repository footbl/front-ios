// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Team.m instead.

#import "_Team.h"

const struct TeamAttributes TeamAttributes = {
	.acronym = @"acronym",
	.name = @"name",
	.picture = @"picture",
};

const struct TeamRelationships TeamRelationships = {
	.championships = @"championships",
	.guestMatches = @"guestMatches",
	.hostMatches = @"hostMatches",
};

const struct TeamFetchedProperties TeamFetchedProperties = {
};

@implementation TeamID
@end

@implementation _Team

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Team" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Team";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Team" inManagedObjectContext:moc_];
}

- (TeamID*)objectID {
	return (TeamID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic acronym;






@dynamic name;






@dynamic picture;






@dynamic championships;

	
- (NSMutableSet*)championshipsSet {
	[self willAccessValueForKey:@"championships"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"championships"];
  
	[self didAccessValueForKey:@"championships"];
	return result;
}
	

@dynamic guestMatches;

	
- (NSMutableSet*)guestMatchesSet {
	[self willAccessValueForKey:@"guestMatches"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"guestMatches"];
  
	[self didAccessValueForKey:@"guestMatches"];
	return result;
}
	

@dynamic hostMatches;

	
- (NSMutableSet*)hostMatchesSet {
	[self willAccessValueForKey:@"hostMatches"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"hostMatches"];
  
	[self didAccessValueForKey:@"hostMatches"];
	return result;
}
	






@end
