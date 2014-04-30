// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Bet.h instead.

#import <CoreData/CoreData.h>
#import "FootblModel.h"

extern const struct BetAttributes {
	__unsafe_unretained NSString *date;
	__unsafe_unretained NSString *finished;
	__unsafe_unretained NSString *result;
	__unsafe_unretained NSString *reward;
	__unsafe_unretained NSString *value;
} BetAttributes;

extern const struct BetRelationships {
	__unsafe_unretained NSString *match;
	__unsafe_unretained NSString *wallet;
} BetRelationships;

extern const struct BetFetchedProperties {
} BetFetchedProperties;

@class Match;
@class Wallet;







@interface BetID : NSManagedObjectID {}
@end

@interface _Bet : FootblModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (BetID*)objectID;





@property (nonatomic, strong) NSDate* date;



//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* finished;



@property BOOL finishedValue;
- (BOOL)finishedValue;
- (void)setFinishedValue:(BOOL)value_;

//- (BOOL)validateFinished:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* result;



@property int64_t resultValue;
- (int64_t)resultValue;
- (void)setResultValue:(int64_t)value_;

//- (BOOL)validateResult:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* reward;



@property float rewardValue;
- (float)rewardValue;
- (void)setRewardValue:(float)value_;

//- (BOOL)validateReward:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* value;



@property float valueValue;
- (float)valueValue;
- (void)setValueValue:(float)value_;

//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Match *match;

//- (BOOL)validateMatch:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) Wallet *wallet;

//- (BOOL)validateWallet:(id*)value_ error:(NSError**)error_;





@end

@interface _Bet (CoreDataGeneratedAccessors)

@end

@interface _Bet (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;




- (NSNumber*)primitiveFinished;
- (void)setPrimitiveFinished:(NSNumber*)value;

- (BOOL)primitiveFinishedValue;
- (void)setPrimitiveFinishedValue:(BOOL)value_;




- (NSNumber*)primitiveResult;
- (void)setPrimitiveResult:(NSNumber*)value;

- (int64_t)primitiveResultValue;
- (void)setPrimitiveResultValue:(int64_t)value_;




- (NSNumber*)primitiveReward;
- (void)setPrimitiveReward:(NSNumber*)value;

- (float)primitiveRewardValue;
- (void)setPrimitiveRewardValue:(float)value_;




- (NSNumber*)primitiveValue;
- (void)setPrimitiveValue:(NSNumber*)value;

- (float)primitiveValueValue;
- (void)setPrimitiveValueValue:(float)value_;





- (Match*)primitiveMatch;
- (void)setPrimitiveMatch:(Match*)value;



- (Wallet*)primitiveWallet;
- (void)setPrimitiveWallet:(Wallet*)value;


@end
