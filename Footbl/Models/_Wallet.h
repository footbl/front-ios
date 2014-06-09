// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Wallet.h instead.

#import <CoreData/CoreData.h>
#import "FootblModel.h"

extern const struct WalletAttributes {
	__unsafe_unretained NSString *active;
	__unsafe_unretained NSString *funds;
	__unsafe_unretained NSString *lastRounds;
	__unsafe_unretained NSString *maxFunds;
	__unsafe_unretained NSString *maxFundsDate;
	__unsafe_unretained NSString *ranking;
	__unsafe_unretained NSString *stake;
} WalletAttributes;

extern const struct WalletRelationships {
	__unsafe_unretained NSString *bets;
	__unsafe_unretained NSString *championship;
	__unsafe_unretained NSString *user;
} WalletRelationships;

extern const struct WalletFetchedProperties {
} WalletFetchedProperties;

@class Bet;
@class Championship;
@class User;



@class NSObject;





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





@property (nonatomic, strong) id lastRounds;



//- (BOOL)validateLastRounds:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* maxFunds;



@property int64_t maxFundsValue;
- (int64_t)maxFundsValue;
- (void)setMaxFundsValue:(int64_t)value_;

//- (BOOL)validateMaxFunds:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* maxFundsDate;



//- (BOOL)validateMaxFundsDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* ranking;



@property int64_t rankingValue;
- (int64_t)rankingValue;
- (void)setRankingValue:(int64_t)value_;

//- (BOOL)validateRanking:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* stake;



@property int64_t stakeValue;
- (int64_t)stakeValue;
- (void)setStakeValue:(int64_t)value_;

//- (BOOL)validateStake:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *bets;

- (NSMutableSet*)betsSet;




@property (nonatomic, strong) Championship *championship;

//- (BOOL)validateChampionship:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) User *user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;





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




- (id)primitiveLastRounds;
- (void)setPrimitiveLastRounds:(id)value;




- (NSNumber*)primitiveMaxFunds;
- (void)setPrimitiveMaxFunds:(NSNumber*)value;

- (int64_t)primitiveMaxFundsValue;
- (void)setPrimitiveMaxFundsValue:(int64_t)value_;




- (NSDate*)primitiveMaxFundsDate;
- (void)setPrimitiveMaxFundsDate:(NSDate*)value;




- (NSNumber*)primitiveRanking;
- (void)setPrimitiveRanking:(NSNumber*)value;

- (int64_t)primitiveRankingValue;
- (void)setPrimitiveRankingValue:(int64_t)value_;




- (NSNumber*)primitiveStake;
- (void)setPrimitiveStake:(NSNumber*)value;

- (int64_t)primitiveStakeValue;
- (void)setPrimitiveStakeValue:(int64_t)value_;





- (NSMutableSet*)primitiveBets;
- (void)setPrimitiveBets:(NSMutableSet*)value;



- (Championship*)primitiveChampionship;
- (void)setPrimitiveChampionship:(Championship*)value;



- (User*)primitiveUser;
- (void)setPrimitiveUser:(User*)value;


@end
