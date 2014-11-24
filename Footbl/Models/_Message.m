// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Message.m instead.

#import "_Message.h"

const struct MessageAttributes MessageAttributes = {
	.message = @"message",
	.typeString = @"typeString",
};

const struct MessageRelationships MessageRelationships = {
	.group = @"group",
	.user = @"user",
};

@implementation MessageID
@end

@implementation _Message

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Message";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Message" inManagedObjectContext:moc_];
}

- (MessageID*)objectID {
	return (MessageID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic message;

@dynamic typeString;

@dynamic group;

@dynamic user;

@end

