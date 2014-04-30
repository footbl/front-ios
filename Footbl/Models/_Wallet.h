// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Wallet.h instead.

#import <CoreData/CoreData.h>
#import "FootblModel.h"

extern const struct WalletAttributes {
	__unsafe_unretained NSString *active;
	__unsafe_unretained NSString *funds;
	__unsafe_unretained NSString *profit;
	__unsafe_unretained NSString *stake;
	__unsafe_unretained NSString *toReturn;
} WalletAttributes;

extern const struct WalletRelationships {
	__unsafe_unretained NSString *bets;
	__unsafe_unretained NSString *championship;
} WalletRelationships;

extern const struct WalletFetchedProperties {
} WalletFetchedProperties;

@class Bet;
@class Championship;







@interface WalletID : NSManagedObjectID {}
@end

@interface _Wallet : FootblModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WalletID*)objectID;





@property (nonatomic, strong) NSNumber* active;



@property BOOL activeValue;
- (BOOL)activeValue;
- (void)setActiveValue:(BOOL)value_;

//- (BOOL)validateActive:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* funds;



@property int64_t fundsValue;
- (int64_t)fundsValue;
- (void)setFundsValue:(int64_t)value_;

//- (BOOL)validateFunds:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* profit;



@property int64_t profitValue;
- (int64_t)profitValue;
- (void)setProfitValue:(int64_t)value_;

//- (BOOL)validateProfit:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* stake;



@property int64_t stakeValue;
- (int64_t)stakeValue;
- (void)setStakeValue:(int64_t)value_;

//- (BOOL)validateStake:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* toReturn;



@property int64_t toReturnValue;
- (int64_t)toReturnValue;
- (void)setToReturnValue:(int64_t)value_;

//- (BOOL)validateToReturn:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *bets;

- (NSMutableSet*)betsSet;




@property (nonatomic, strong) Championship *championship;

//- (BOOL)validateChampionship:(id*)value_ error:(NSError**)error_;





@end

@interface _Wallet (CoreDataGeneratedAccessors)

- (void)addBets:(NSSet*)value_;
- (void)removeBets:(NSSet*)value_;
- (void)addBetsObject:(Bet*)value_;
- (void)removeBetsObject:(Bet*)value_;

@end

@interface _Wallet (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveActive;
- (void)setPrimitiveActive:(NSNumber*)value;

- (BOOL)primitiveActiveValue;
- (void)setPrimitiveActiveValue:(BOOL)value_;




- (NSNumber*)primitiveFunds;
- (void)setPrimitiveFunds:(NSNumber*)value;

- (int64_t)primitiveFundsValue;
- (void)setPrimitiveFundsValue:(int64_t)value_;




- (NSNumber*)primitiveProfit;
- (void)setPrimitiveProfit:(NSNumber*)value;

- (int64_t)primitiveProfitValue;
- (void)setPrimitiveProfitValue:(int64_t)value_;




- (NSNumber*)primitiveStake;
- (void)setPrimitiveStake:(NSNumber*)value;

- (int64_t)primitiveStakeValue;
- (void)setPrimitiveStakeValue:(int64_t)value_;




- (NSNumber*)primitiveToReturn;
- (void)setPrimitiveToReturn:(NSNumber*)value;

- (int64_t)primitiveToReturnValue;
- (void)setPrimitiveToReturnValue:(int64_t)value_;





- (NSMutableSet*)primitiveBets;
- (void)setPrimitiveBets:(NSMutableSet*)value;



- (Championship*)primitiveChampionship;
- (void)setPrimitiveChampionship:(Championship*)value;


@end
