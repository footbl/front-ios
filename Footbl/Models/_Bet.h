// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Bet.h instead.

#import <CoreData/CoreData.h>
#import "FTModel.h"

extern const struct BetAttributes {
	__unsafe_unretained NSString *bid;
	__unsafe_unretained NSString *result;
} BetAttributes;

extern const struct BetRelationships {
	__unsafe_unretained NSString *match;
	__unsafe_unretained NSString *user;
} BetRelationships;

extern const struct BetFetchedProperties {
} BetFetchedProperties;

@class Match;
@class User;




@interface BetID : NSManagedObjectID {}
@end

@interface _Bet : FTModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (BetID*)objectID;





@property (nonatomic, strong) NSNumber* bid;



@property int64_t bidValue;
- (int64_t)bidValue;
- (void)setBidValue:(int64_t)value_;

//- (BOOL)validateBid:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* result;



@property int64_t resultValue;
- (int64_t)resultValue;
- (void)setResultValue:(int64_t)value_;

//- (BOOL)validateResult:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Match *match;

//- (BOOL)validateMatch:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) User *user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;





@end

@interface _Bet (CoreDataGeneratedAccessors)

@end

@interface _Bet (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveBid;
- (void)setPrimitiveBid:(NSNumber*)value;

- (int64_t)primitiveBidValue;
- (void)setPrimitiveBidValue:(int64_t)value_;




- (NSNumber*)primitiveResult;
- (void)setPrimitiveResult:(NSNumber*)value;

- (int64_t)primitiveResultValue;
- (void)setPrimitiveResultValue:(int64_t)value_;





- (Match*)primitiveMatch;
- (void)setPrimitiveMatch:(Match*)value;



- (User*)primitiveUser;
- (void)setPrimitiveUser:(User*)value;


@end
