// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.m instead.

#import "_User.h"

const struct UserAttributes UserAttributes = {
	.about = @"about",
	.createdAt = @"createdAt",
	.email = @"email",
	.featured = @"featured",
	.name = @"name",
	.picture = @"picture",
	.username = @"username",
	.verified = @"verified",
};

const struct UserRelationships UserRelationships = {
	.comments = @"comments",
	.memberships = @"memberships",
	.ownedGroups = @"ownedGroups",
	.starredByUsers = @"starredByUsers",
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
	if ([key isEqualToString:@"verifiedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"verified"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic about;






@dynamic createdAt;






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





@dynamic name;






@dynamic picture;






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





@dynamic comments;

	
- (NSMutableSet*)commentsSet {
	[self willAccessValueForKey:@"comments"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"comments"];
  
	[self didAccessValueForKey:@"comments"];
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
	

@dynamic starredByUsers;

	
- (NSMutableSet*)starredByUsersSet {
	[self willAccessValueForKey:@"starredByUsers"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"starredByUsers"];
  
	[self didAccessValueForKey:@"starredByUsers"];
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
