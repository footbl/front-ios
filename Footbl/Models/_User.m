// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.m instead.

#import "_User.h"

const struct UserAttributes UserAttributes = {
	.about = @"about",
	.email = @"email",
	.featured = @"featured",
	.followers = @"followers",
	.funds = @"funds",
	.history = @"history",
	.isMe = @"isMe",
	.name = @"name",
	.picture = @"picture",
	.previousRanking = @"previousRanking",
	.ranking = @"ranking",
	.stake = @"stake",
	.username = @"username",
	.verified = @"verified",
};

const struct UserRelationships UserRelationships = {
	.bets = @"bets",
	.fans = @"fans",
	.memberships = @"memberships",
	.ownedGroups = @"ownedGroups",
	.starredUsers = @"starredUsers",
	.wallets = @"wallets",
};

const struct UserFetchedProperties UserFetchedProperties = {
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
	if ([key isEqualToString:@"followersValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"followers"];
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





@dynamic followers;



- (int64_t)followersValue {
	NSNumber *result = [self followers];
	return [result longLongValue];
}

- (void)setFollowersValue:(int64_t)value_ {
	[self setFollowers:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveFollowersValue {
	NSNumber *result = [self primitiveFollowers];
	return [result longLongValue];
}

- (void)setPrimitiveFollowersValue:(int64_t)value_ {
	[self setPrimitiveFollowers:[NSNumber numberWithLongLong:value_]];
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
	

@dynamic fans;

	
- (NSMutableSet*)fansSet {
	[self willAccessValueForKey:@"fans"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"fans"];
  
	[self didAccessValueForKey:@"fans"];
	return result;
}
	

@dynamic memberships;

	
- (NSMutableSet*)membershipsSet {
	[self willAccessValueForKey:@"memberships"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"memberships"];
  
	[self didAccessValueForKey:@"memberships"];
	return result;
}
	

@dynamic ownedGroups;

	
- (NSMutableSet*)ownedGroupsSet {
	[self willAccessValueForKey:@"ownedGroups"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"ownedGroups"];
  
	[self didAccessValueForKey:@"ownedGroups"];
	return result;
}
	

@dynamic starredUsers;

	
- (NSMutableSet*)starredUsersSet {
	[self willAccessValueForKey:@"starredUsers"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"starredUsers"];
  
	[self didAccessValueForKey:@"starredUsers"];
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
