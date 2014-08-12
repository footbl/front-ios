// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FTModel.m instead.

#import "_FTModel.h"

const struct FTModelAttributes FTModelAttributes = {
	.rid = @"rid",
	.slug = @"slug",
};

const struct FTModelRelationships FTModelRelationships = {
};

const struct FTModelFetchedProperties FTModelFetchedProperties = {
};

@implementation FTModelID
@end

@implementation _FTModel

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"FTModel" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"FTModel";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"FTModel" inManagedObjectContext:moc_];
}

- (FTModelID*)objectID {
	return (FTModelID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic rid;






@dynamic slug;











@end
