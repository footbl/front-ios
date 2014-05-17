// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Group.m instead.

#import "_Group.h"

const struct GroupAttributes GroupAttributes = {
	.freeToEdit = @"freeToEdit",
	.isDefault = @"isDefault",
	.isNew = @"isNew",
	.name = @"name",
	.removed = @"removed",
};

const struct GroupRelationships GroupRelationships = {
	.championship = @"championship",
	.members = @"members",
	.owner = @"owner",
};

const struct GroupFetchedProperties GroupFetchedProperties = {
};

@implementation GroupID
@end

@implementation _Group

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Group";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Group" inManagedObjectContext:moc_];
}

- (GroupID*)objectID {
	return (GroupID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"freeToEditValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"freeToEdit"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isDefaultValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isDefault"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isNewValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isNew"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"removedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"removed"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic freeToEdit;



- (BOOL)freeToEditValue {
	NSNumber *result = [self freeToEdit];
	return [result boolValue];
}

- (void)setFreeToEditValue:(BOOL)value_ {
	[self setFreeToEdit:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveFreeToEditValue {
	NSNumber *result = [self primitiveFreeToEdit];
	return [result boolValue];
}

- (void)setPrimitiveFreeToEditValue:(BOOL)value_ {
	[self setPrimitiveFreeToEdit:[NSNumber numberWithBool:value_]];
}





@dynamic isDefault;



- (BOOL)isDefaultValue {
	NSNumber *result = [self isDefault];
	return [result boolValue];
}

- (void)setIsDefaultValue:(BOOL)value_ {
	[self setIsDefault:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsDefaultValue {
	NSNumber *result = [self primitiveIsDefault];
	return [result boolValue];
}

- (void)setPrimitiveIsDefaultValue:(BOOL)value_ {
	[self setPrimitiveIsDefault:[NSNumber numberWithBool:value_]];
}





@dynamic isNew;



- (BOOL)isNewValue {
	NSNumber *result = [self isNew];
	return [result boolValue];
}

- (void)setIsNewValue:(BOOL)value_ {
	[self setIsNew:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsNewValue {
	NSNumber *result = [self primitiveIsNew];
	return [result boolValue];
}

- (void)setPrimitiveIsNewValue:(BOOL)value_ {
	[self setPrimitiveIsNew:[NSNumber numberWithBool:value_]];
}





@dynamic name;






@dynamic removed;



- (BOOL)removedValue {
	NSNumber *result = [self removed];
	return [result boolValue];
}

- (void)setRemovedValue:(BOOL)value_ {
	[self setRemoved:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveRemovedValue {
	NSNumber *result = [self primitiveRemoved];
	return [result boolValue];
}

- (void)setPrimitiveRemovedValue:(BOOL)value_ {
	[self setPrimitiveRemoved:[NSNumber numberWithBool:value_]];
}





@dynamic championship;

	

@dynamic members;

	
- (NSMutableSet*)membersSet {
	[self willAccessValueForKey:@"members"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"members"];
  
	[self didAccessValueForKey:@"members"];
	return result;
}
	

@dynamic owner;

	






@end
