// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Wallet.m instead.

#import "_Wallet.h"

const struct WalletAttributes WalletAttributes = {
	.active = @"active",
	.funds = @"funds",
	.lastRounds = @"lastRounds",
	.maxFunds = @"maxFunds",
	.ranking = @"ranking",
	.stake = @"stake",
};

const struct WalletRelationships WalletRelationships = {
	.bets = @"bets",
	.championship = @"championship",
	.user = @"user",
};

const struct WalletFetchedProperties WalletFetchedProperties = {
};

@implementation WalletID
@end

@implementation _Wallet

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Wallet" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Wallet";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Wallet" inManagedObjectContext:moc_];
}

- (WalletID*)objectID {
	return (WalletID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"activeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"active"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"fundsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"funds"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"maxFundsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"maxFunds"];
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

	return keyPaths;
}




@dynamic active;



- (BOOL)activeValue {
	NSNumber *result = [self active];
	return [result boolValue];
}

- (void)setActiveValue:(BOOL)value_ {
	[self setActive:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveActiveValue {
	NSNumber *result = [self primitiveActive];
	return [result boolValue];
}

- (void)setPrimitiveActiveValue:(BOOL)value_ {
	[self setPrimitiveActive:[NSNumber numberWithBool:value_]];
}





@dynamic funds;



- (int64_t)fundsValue {
	NSNumber *result = [self funds];
	return [result longLongValue];
}

- (void)setFundsValue:(int64_t)value_ {
	[self setFunds:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveFundsValue {
	NSNumber *result = [self primitiveFunds];
	return [result longLongValue];
}

- (void)setPrimitiveFundsValue:(int64_t)value_ {
	[self setPrimitiveFunds:[NSNumber numberWithLongLong:value_]];
}





@dynamic lastRounds;






@dynamic maxFunds;



- (int64_t)maxFundsValue {
	NSNumber *result = [self maxFunds];
	return [result longLongValue];
}

- (void)setMaxFundsValue:(int64_t)value_ {
	[self setMaxFunds:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveMaxFundsValue {
	NSNumber *result = [self primitiveMaxFunds];
	return [result longLongValue];
}

- (void)setPrimitiveMaxFundsValue:(int64_t)value_ {
	[self setPrimitiveMaxFunds:[NSNumber numberWithLongLong:value_]];
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





@dynamic bets;

	
- (NSMutableSet*)betsSet {
	[self willAccessValueForKey:@"bets"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"bets"];
  
	[self didAccessValueForKey:@"bets"];
	return result;
}
	

@dynamic championship;

	

@dynamic user;

	






@end
