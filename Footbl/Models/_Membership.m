// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Membership.m instead.

#import "_Membership.h"

const struct MembershipAttributes MembershipAttributes = {
	.previousRanking = @"previousRanking",
	.ranking = @"ranking",
};

const struct MembershipRelationships MembershipRelationships = {
	.group = @"group",
	.user = @"user",
};

const struct MembershipFetchedProperties MembershipFetchedProperties = {
};

@implementation MembershipID
@end

@implementation _Membership

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Membership" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Membership";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Membership" inManagedObjectContext:moc_];
}

- (MembershipID*)objectID {
	return (MembershipID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"previousRankingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"previousRanking"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"rankingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"ranking"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic previousRanking;



- (int64_t)previousRankingValue {
	NSNumber *result = [self previousRanking];
	return [result longLongValue];
}

- (void)setPreviousRankingValue:(int64_t)value_ {
	[self setPreviousRanking:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitivePreviousRankingValue {
	NSNumber *result = [self primitivePreviousRanking];
	return [result longLongValue];
}

- (void)setPrimitivePreviousRankingValue:(int64_t)value_ {
	[self setPrimitivePreviousRanking:[NSNumber numberWithLongLong:value_]];
}





@dynamic ranking;



- (int64_t)rankingValue {
	NSNumber *result = [self ranking];
	return [result longLongValue];
}

- (void)setRankingValue:(int64_t)value_ {
	[self setRanking:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveRankingValue {
	NSNumber *result = [self primitiveRanking];
	return [result longLongValue];
}

- (void)setPrimitiveRankingValue:(int64_t)value_ {
	[self setPrimitiveRanking:[NSNumber numberWithLongLong:value_]];
}





@dynamic group;

	

@dynamic user;

	






@end
