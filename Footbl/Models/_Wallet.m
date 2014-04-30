// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Wallet.m instead.

#import "_Wallet.h"

const struct WalletAttributes WalletAttributes = {
	.active = @"active",
	.funds = @"funds",
	.profit = @"profit",
	.stake = @"stake",
	.toReturn = @"toReturn",
};

const struct WalletRelationships WalletRelationships = {
	.bets = @"bets",
	.championship = @"championship",
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
	if ([key isEqualToString:@"profitValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"profit"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"stakeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"stake"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"toReturnValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"toReturn"];
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





@dynamic profit;



- (int64_t)profitValue {
	NSNumber *result = [self profit];
	return [result longLongValue];
}

- (void)setProfitValue:(int64_t)value_ {
	[self setProfit:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveProfitValue {
	NSNumber *result = [self primitiveProfit];
	return [result longLongValue];
}

- (void)setPrimitiveProfitValue:(int64_t)value_ {
	[self setPrimitiveProfit:[NSNumber numberWithLongLong:value_]];
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





@dynamic toReturn;



- (int64_t)toReturnValue {
	NSNumber *result = [self toReturn];
	return [result longLongValue];
}

- (void)setToReturnValue:(int64_t)value_ {
	[self setToReturn:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveToReturnValue {
	NSNumber *result = [self primitiveToReturn];
	return [result longLongValue];
}

- (void)setPrimitiveToReturnValue:(int64_t)value_ {
	[self setPrimitiveToReturn:[NSNumber numberWithLongLong:value_]];
}





@dynamic bets;

	
- (NSMutableSet*)betsSet {
	[self willAccessValueForKey:@"bets"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"bets"];
  
	[self didAccessValueForKey:@"bets"];
	return result;
}
	

@dynamic championship;

	






@end
