// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.m instead.

#import "_User.h"

const struct UserAttributes UserAttributes = {
	.about = @"about",
	.email = @"email",
	.featured = @"featured",
	.funds = @"funds",
	.history = @"history",
	.isMe = @"isMe",
	.name = @"name",
	.numberOfFans = @"numberOfFans",
	.numberOfLeagues = @"numberOfLeagues",
	.picture = @"picture",
	.previousRanking = @"previousRanking",
	.ranking = @"ranking",
	.stake = @"stake",
	.username = @"username",
	.verified = @"verified",
};

const struct UserRelationships UserRelationships = {
	.bets = @"bets",
	.chargeRequests = @"chargeRequests",
	.creditRequests = @"creditRequests",
	.fanByUsers = @"fanByUsers",
	.fanOfUsers = @"fanOfUsers",
	.memberships = @"memberships",
	.messages = @"messages",
	.ownedGroups = @"ownedGroups",
	.prizes = @"prizes",
};

@implementation UserID
@end

@implementation _User

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"User";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"User" inManagedObjectContext:moc_];
}

- (UserID*)objectID {
	return (UserID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"featuredValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"featured"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"fundsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"funds"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isMeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isMe"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"numberOfFansValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"numberOfFans"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"numberOfLeaguesValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"numberOfLeagues"];
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
	if ([key isEqualToString:@"stakeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"stake"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"verifiedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"verified"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic about;

@dynamic email;

@dynamic featured;

- (BOOL)featuredValue {
	NSNumber *result = [self featured];
	return [result boolValue];
}

- (void)setFeaturedValue:(BOOL)value_ {
	[self setFeatured:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveFeaturedValue {
	NSNumber *result = [self primitiveFeatured];
	return [result boolValue];
}

- (void)setPrimitiveFeaturedValue:(BOOL)value_ {
	[self setPrimitiveFeatured:[NSNumber numberWithBool:value_]];
}

@dynamic funds;

- (float)fundsValue {
	NSNumber *result = [self funds];
	return [result floatValue];
}

- (void)setFundsValue:(float)value_ {
	[self setFunds:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveFundsValue {
	NSNumber *result = [self primitiveFunds];
	return [result floatValue];
}

- (void)setPrimitiveFundsValue:(float)value_ {
	[self setPrimitiveFunds:[NSNumber numberWithFloat:value_]];
}

@dynamic history;

@dynamic isMe;

- (BOOL)isMeValue {
	NSNumber *result = [self isMe];
	return [result boolValue];
}

- (void)setIsMeValue:(BOOL)value_ {
	[self setIsMe:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsMeValue {
	NSNumber *result = [self primitiveIsMe];
	return [result boolValue];
}

- (void)setPrimitiveIsMeValue:(BOOL)value_ {
	[self setPrimitiveIsMe:[NSNumber numberWithBool:value_]];
}

@dynamic name;

@dynamic numberOfFans;

- (int64_t)numberOfFansValue {
	NSNumber *result = [self numberOfFans];
	return [result longLongValue];
}

- (void)setNumberOfFansValue:(int64_t)value_ {
	[self setNumberOfFans:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveNumberOfFansValue {
	NSNumber *result = [self primitiveNumberOfFans];
	return [result longLongValue];
}

- (void)setPrimitiveNumberOfFansValue:(int64_t)value_ {
	[self setPrimitiveNumberOfFans:[NSNumber numberWithLongLong:value_]];
}

@dynamic numberOfLeagues;

- (int64_t)numberOfLeaguesValue {
	NSNumber *result = [self numberOfLeagues];
	return [result longLongValue];
}

- (void)setNumberOfLeaguesValue:(int64_t)value_ {
	[self setNumberOfLeagues:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveNumberOfLeaguesValue {
	NSNumber *result = [self primitiveNumberOfLeagues];
	return [result longLongValue];
}

- (void)setPrimitiveNumberOfLeaguesValue:(int64_t)value_ {
	[self setPrimitiveNumberOfLeagues:[NSNumber numberWithLongLong:value_]];
}

@dynamic picture;

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

@dynamic stake;

- (int64_t)stakeValue {
	NSNumber *result = [self stake];
	return [result longLongValue];
}

- (void)setStakeValue:(int64_t)value_ {
	[self setStake:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveStakeValue {
	NSNumber *result = [self primitiveStake];
	return [result longLongValue];
}

- (void)setPrimitiveStakeValue:(int64_t)value_ {
	[self setPrimitiveStake:[NSNumber numberWithLongLong:value_]];
}

@dynamic username;

@dynamic verified;

- (BOOL)verifiedValue {
	NSNumber *result = [self verified];
	return [result boolValue];
}

- (void)setVerifiedValue:(BOOL)value_ {
	[self setVerified:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveVerifiedValue {
	NSNumber *result = [self primitiveVerified];
	return [result boolValue];
}

- (void)setPrimitiveVerifiedValue:(BOOL)value_ {
	[self setPrimitiveVerified:[NSNumber numberWithBool:value_]];
}

@dynamic bets;

- (NSMutableSet*)betsSet {
	[self willAccessValueForKey:@"bets"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"bets"];

	[self didAccessValueForKey:@"bets"];
	return result;
}

@dynamic chargeRequests;

@dynamic creditRequests;

- (NSMutableSet*)creditRequestsSet {
	[self willAccessValueForKey:@"creditRequests"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"creditRequests"];

	[self didAccessValueForKey:@"creditRequests"];
	return result;
}

@dynamic fanByUsers;

- (NSMutableSet*)fanByUsersSet {
	[self willAccessValueForKey:@"fanByUsers"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"fanByUsers"];

	[self didAccessValueForKey:@"fanByUsers"];
	return result;
}

@dynamic fanOfUsers;

- (NSMutableSet*)fanOfUsersSet {
	[self willAccessValueForKey:@"fanOfUsers"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"fanOfUsers"];

	[self didAccessValueForKey:@"fanOfUsers"];
	return result;
}

@dynamic memberships;

- (NSMutableSet*)membershipsSet {
	[self willAccessValueForKey:@"memberships"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"memberships"];

	[self didAccessValueForKey:@"memberships"];
	return result;
}

@dynamic messages;

- (NSMutableSet*)messagesSet {
	[self willAccessValueForKey:@"messages"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"messages"];

	[self didAccessValueForKey:@"messages"];
	return result;
}

@dynamic ownedGroups;

- (NSMutableSet*)ownedGroupsSet {
	[self willAccessValueForKey:@"ownedGroups"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"ownedGroups"];

	[self didAccessValueForKey:@"ownedGroups"];
	return result;
}

@dynamic prizes;

- (NSMutableSet*)prizesSet {
	[self willAccessValueForKey:@"prizes"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"prizes"];

	[self didAccessValueForKey:@"prizes"];
	return result;
}

@end

