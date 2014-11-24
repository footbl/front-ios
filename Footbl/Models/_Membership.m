// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Membership.m instead.

#import "_Membership.h"

const struct MembershipAttributes MembershipAttributes = {
	.hasRanking = @"hasRanking",
	.isLocalRanking = @"isLocalRanking",
	.notifications = @"notifications",
	.previousRanking = @"previousRanking",
	.ranking = @"ranking",
};

const struct MembershipRelationships MembershipRelationships = {
	.group = @"group",
	.user = @"user",
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

	if ([key isEqualToString:@"hasRankingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"hasRanking"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isLocalRankingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isLocalRanking"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"notificationsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"notifications"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
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

@dynamic hasRanking;

- (BOOL)hasRankingValue {
	NSNumber *result = [self hasRanking];
	return [result boolValue];
}

- (void)setHasRankingValue:(BOOL)value_ {
	[self setHasRanking:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveHasRankingValue {
	NSNumber *result = [self primitiveHasRanking];
	return [result boolValue];
}

- (void)setPrimitiveHasRankingValue:(BOOL)value_ {
	[self setPrimitiveHasRanking:[NSNumber numberWithBool:value_]];
}

@dynamic isLocalRanking;

- (BOOL)isLocalRankingValue {
	NSNumber *result = [self isLocalRanking];
	return [result boolValue];
}

- (void)setIsLocalRankingValue:(BOOL)value_ {
	[self setIsLocalRanking:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsLocalRankingValue {
	NSNumber *result = [self primitiveIsLocalRanking];
	return [result boolValue];
}

- (void)setPrimitiveIsLocalRankingValue:(BOOL)value_ {
	[self setPrimitiveIsLocalRanking:[NSNumber numberWithBool:value_]];
}

@dynamic notifications;

- (BOOL)notificationsValue {
	NSNumber *result = [self notifications];
	return [result boolValue];
}

- (void)setNotificationsValue:(BOOL)value_ {
	[self setNotifications:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveNotificationsValue {
	NSNumber *result = [self primitiveNotifications];
	return [result boolValue];
}

- (void)setPrimitiveNotificationsValue:(BOOL)value_ {
	[self setPrimitiveNotifications:[NSNumber numberWithBool:value_]];
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

