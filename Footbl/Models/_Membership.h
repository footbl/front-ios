// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Membership.h instead.

#import <CoreData/CoreData.h>
#import "FTModel.h"

extern const struct MembershipAttributes {
	__unsafe_unretained NSString *hasRanking;
	__unsafe_unretained NSString *previousRanking;
	__unsafe_unretained NSString *ranking;
} MembershipAttributes;

extern const struct MembershipRelationships {
	__unsafe_unretained NSString *group;
	__unsafe_unretained NSString *user;
} MembershipRelationships;

extern const struct MembershipFetchedProperties {
} MembershipFetchedProperties;

@class Group;
@class User;





@interface MembershipID : NSManagedObjectID {}
@end

@interface _Membership : FTModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MembershipID*)objectID;





@property (nonatomic, strong) NSNumber* hasRanking;



@property BOOL hasRankingValue;
- (BOOL)hasRankingValue;
- (void)setHasRankingValue:(BOOL)value_;

//- (BOOL)validateHasRanking:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* previousRanking;



@property int64_t previousRankingValue;
- (int64_t)previousRankingValue;
- (void)setPreviousRankingValue:(int64_t)value_;

//- (BOOL)validatePreviousRanking:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* ranking;



@property int64_t rankingValue;
- (int64_t)rankingValue;
- (void)setRankingValue:(int64_t)value_;

//- (BOOL)validateRanking:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Group *group;

//- (BOOL)validateGroup:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) User *user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;





@end

@interface _Membership (CoreDataGeneratedAccessors)

@end

@interface _Membership (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveHasRanking;
- (void)setPrimitiveHasRanking:(NSNumber*)value;

- (BOOL)primitiveHasRankingValue;
- (void)setPrimitiveHasRankingValue:(BOOL)value_;




- (NSNumber*)primitivePreviousRanking;
- (void)setPrimitivePreviousRanking:(NSNumber*)value;

- (int64_t)primitivePreviousRankingValue;
- (void)setPrimitivePreviousRankingValue:(int64_t)value_;




- (NSNumber*)primitiveRanking;
- (void)setPrimitiveRanking:(NSNumber*)value;

- (int64_t)primitiveRankingValue;
- (void)setPrimitiveRankingValue:(int64_t)value_;





- (Group*)primitiveGroup;
- (void)setPrimitiveGroup:(Group*)value;



- (User*)primitiveUser;
- (void)setPrimitiveUser:(User*)value;


@end
