// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Match.m instead.

#import "_Match.h"

const struct MatchAttributes MatchAttributes = {
	.date = @"date",
	.elapsed = @"elapsed",
	.finished = @"finished",
	.guestScore = @"guestScore",
	.hostScore = @"hostScore",
	.jackpot = @"jackpot",
	.localUpdatedAt = @"localUpdatedAt",
	.potDraw = @"potDraw",
	.potGuest = @"potGuest",
	.potHost = @"potHost",
	.round = @"round",
};

const struct MatchRelationships MatchRelationships = {
	.bets = @"bets",
	.championship = @"championship",
	.guest = @"guest",
	.host = @"host",
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
	if ([key isEqualToString:@"jackpotValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"jackpot"];
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

- (int32_t)elapsedValue {
	NSNumber *result = [self elapsed];
	return [result intValue];
}

- (void)setElapsedValue:(int32_t)value_ {
	[self setElapsed:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveElapsedValue {
	NSNumber *result = [self primitiveElapsed];
	return [result intValue];
}

- (void)setPrimitiveElapsedValue:(int32_t)value_ {
	[self setPrimitiveElapsed:[NSNumber numberWithInt:value_]];
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

- (int32_t)guestScoreValue {
	NSNumber *result = [self guestScore];
	return [result intValue];
}

- (void)setGuestScoreValue:(int32_t)value_ {
	[self setGuestScore:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveGuestScoreValue {
	NSNumber *result = [self primitiveGuestScore];
	return [result intValue];
}

- (void)setPrimitiveGuestScoreValue:(int32_t)value_ {
	[self setPrimitiveGuestScore:[NSNumber numberWithInt:value_]];
}

@dynamic hostScore;

- (int32_t)hostScoreValue {
	NSNumber *result = [self hostScore];
	return [result intValue];
}

- (void)setHostScoreValue:(int32_t)value_ {
	[self setHostScore:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveHostScoreValue {
	NSNumber *result = [self primitiveHostScore];
	return [result intValue];
}

- (void)setPrimitiveHostScoreValue:(int32_t)value_ {
	[self setPrimitiveHostScore:[NSNumber numberWithInt:value_]];
}

@dynamic jackpot;

- (float)jackpotValue {
	NSNumber *result = [self jackpot];
	return [result floatValue];
}

- (void)setJackpotValue:(float)value_ {
	[self setJackpot:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveJackpotValue {
	NSNumber *result = [self primitiveJackpot];
	return [result floatValue];
}

- (void)setPrimitiveJackpotValue:(float)value_ {
	[self setPrimitiveJackpot:[NSNumber numberWithFloat:value_]];
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

- (int32_t)roundValue {
	NSNumber *result = [self round];
	return [result intValue];
}

- (void)setRoundValue:(int32_t)value_ {
	[self setRound:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveRoundValue {
	NSNumber *result = [self primitiveRound];
	return [result intValue];
}

- (void)setPrimitiveRoundValue:(int32_t)value_ {
	[self setPrimitiveRound:[NSNumber numberWithInt:value_]];
}

@dynamic bets;

- (NSMutableSet*)betsSet {
	[self willAccessValueForKey:@"bets"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"bets"];

	[self didAccessValueForKey:@"bets"];
	return result;
}

@dynamic championship;

@dynamic guest;

@dynamic host;

@end

