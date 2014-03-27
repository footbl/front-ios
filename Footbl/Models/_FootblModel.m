// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FootblModel.m instead.

#import "_FootblModel.h"

const struct FootblModelAttributes FootblModelAttributes = {
	.rid = @"rid",
};

const struct FootblModelRelationships FootblModelRelationships = {
};

const struct FootblModelFetchedProperties FootblModelFetchedProperties = {
};

@implementation FootblModelID
@end

@implementation _FootblModel

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"FootblModel" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"FootblModel";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"FootblModel" inManagedObjectContext:moc_];
}

- (FootblModelID*)objectID {
	return (FootblModelID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic rid;











@end
