// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Match.m instead.

#import "_Match.h"

const struct MatchAttributes MatchAttributes = {
	.date = @"date",
	.elapsed = @"elapsed",
	.finished = @"finished",
	.guestScore = @"guestScore",
	.hostScore = @"hostScore",
	.localUpdatedAt = @"localUpdatedAt",
	.potDraw = @"potDraw",
	.potGuest = @"potGuest",
	.potHost = @"potHost",
	.round = @"round",
};

const struct MatchRelationships MatchRelationships = {
	.bet = @"bet",
	.championship = @"championship",
	.comments = @"comments",
	.guest = @"guest",
	.host = @"host",
};

const struct MatchFetchedProperties MatchFetchedProperties = {
};

@implementation MatchID
@end

@implementation _Match

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Match" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Match";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Match" inManagedObjectContext:moc_];
}

- (MatchID*)objectID {
	return (MatchID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"elapsedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"elapsed"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"finishedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"finished"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"guestScoreValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"guestScore"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"hostScoreValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"hostScore"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"potDrawValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"potDraw"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"potGuestValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"potGuest"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"potHostValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"potHost"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"roundValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"round"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic date;






@dynamic elapsed;



- (int16_t)elapsedValue {
	NSNumber *result = [self elapsed];
	return [result shortValue];
}

- (void)setElapsedValue:(int16_t)value_ {
	[self setElapsed:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveElapsedValue {
	NSNumber *result = [self primitiveElapsed];
	return [result shortValue];
}

- (void)setPrimitiveElapsedValue:(int16_t)value_ {
	[self setPrimitiveElapsed:[NSNumber numberWithShort:value_]];
}





@dynamic finished;



- (BOOL)finishedValue {
	NSNumber *result = [self finished];
	return [result boolValue];
}

- (void)setFinishedValue:(BOOL)value_ {
	[self setFinished:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveFinishedValue {
	NSNumber *result = [self primitiveFinished];
	return [result boolValue];
}

- (void)setPrimitiveFinishedValue:(BOOL)value_ {
	[self setPrimitiveFinished:[NSNumber numberWithBool:value_]];
}





@dynamic guestScore;



- (int16_t)guestScoreValue {
	NSNumber *result = [self guestScore];
	return [result shortValue];
}

- (void)setGuestScoreValue:(int16_t)value_ {
	[self setGuestScore:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveGuestScoreValue {
	NSNumber *result = [self primitiveGuestScore];
	return [result shortValue];
}

- (void)setPrimitiveGuestScoreValue:(int16_t)value_ {
	[self setPrimitiveGuestScore:[NSNumber numberWithShort:value_]];
}





@dynamic hostScore;



- (int16_t)hostScoreValue {
	NSNumber *result = [self hostScore];
	return [result shortValue];
}

- (void)setHostScoreValue:(int16_t)value_ {
	[self setHostScore:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveHostScoreValue {
	NSNumber *result = [self primitiveHostScore];
	return [result shortValue];
}

- (void)setPrimitiveHostScoreValue:(int16_t)value_ {
	[self setPrimitiveHostScore:[NSNumber numberWithShort:value_]];
}





@dynamic localUpdatedAt;






@dynamic potDraw;



- (float)potDrawValue {
	NSNumber *result = [self potDraw];
	return [result floatValue];
}

- (void)setPotDrawValue:(float)value_ {
	[self setPotDraw:[NSNumber numberWithFloat:value_]];
}

- (float)primitivePotDrawValue {
	NSNumber *result = [self primitivePotDraw];
	return [result floatValue];
}

- (void)setPrimitivePotDrawValue:(float)value_ {
	[self setPrimitivePotDraw:[NSNumber numberWithFloat:value_]];
}





@dynamic potGuest;



- (float)potGuestValue {
	NSNumber *result = [self potGuest];
	return [result floatValue];
}

- (void)setPotGuestValue:(float)value_ {
	[self setPotGuest:[NSNumber numberWithFloat:value_]];
}

- (float)primitivePotGuestValue {
	NSNumber *result = [self primitivePotGuest];
	return [result floatValue];
}

- (void)setPrimitivePotGuestValue:(float)value_ {
	[self setPrimitivePotGuest:[NSNumber numberWithFloat:value_]];
}





@dynamic potHost;



- (float)potHostValue {
	NSNumber *result = [self potHost];
	return [result floatValue];
}

- (void)setPotHostValue:(float)value_ {
	[self setPotHost:[NSNumber numberWithFloat:value_]];
}

- (float)primitivePotHostValue {
	NSNumber *result = [self primitivePotHost];
	return [result floatValue];
}

- (void)setPrimitivePotHostValue:(float)value_ {
	[self setPrimitivePotHost:[NSNumber numberWithFloat:value_]];
}





@dynamic round;



- (int16_t)roundValue {
	NSNumber *result = [self round];
	return [result shortValue];
}

- (void)setRoundValue:(int16_t)value_ {
	[self setRound:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveRoundValue {
	NSNumber *result = [self primitiveRound];
	return [result shortValue];
}

- (void)setPrimitiveRoundValue:(int16_t)value_ {
	[self setPrimitiveRound:[NSNumber numberWithShort:value_]];
}





@dynamic bet;

	

@dynamic championship;

	

@dynamic comments;

	
- (NSMutableSet*)commentsSet {
	[self willAccessValueForKey:@"comments"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"comments"];
  
	[self didAccessValueForKey:@"comments"];
	return result;
}
	

@dynamic guest;

	

@dynamic host;

	






@end
