// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.m instead.

#import "_User.h"

const struct UserAttributes UserAttributes = {
	.verified = @"verified",
};

const struct UserRelationships UserRelationships = {
	.comments = @"comments",
	.memberships = @"memberships",
	.ownedGroups = @"ownedGroups",
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
	
	if ([key isEqualToString:@"verifiedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"verified"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




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
	






@end
