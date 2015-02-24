// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Entry.m instead.

#import "_Entry.h"

const struct EntryRelationships EntryRelationships = {
	.championship = @"championship",
};

@implementation EntryID
@end

@implementation _Entry

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Entry";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Entry" inManagedObjectContext:moc_];
}

- (EntryID*)objectID {
	return (EntryID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic championship;

@end

