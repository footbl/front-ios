// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Championship.h instead.

#import <CoreData/CoreData.h>
#import "FootblModel.h"

extern const struct ChampionshipAttributes {
	__unsafe_unretained NSString *active;
	__unsafe_unretained NSString *country;
	__unsafe_unretained NSString *currentRound;
	__unsafe_unretained NSString *edition;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *roundFinished;
	__unsafe_unretained NSString *rounds;
} ChampionshipAttributes;

extern const struct ChampionshipRelationships {
	__unsafe_unretained NSString *competitors;
	__unsafe_unretained NSString *defaultGroup;
	__unsafe_unretained NSString *groups;
	__unsafe_unretained NSString *matches;
	__unsafe_unretained NSString *wallet;
} ChampionshipRelationships;

extern const struct ChampionshipFetchedProperties {
} ChampionshipFetchedProperties;

@class Team;
@class Group;
@class Group;
@class Match;
@class Wallet;









@interface ChampionshipID : NSManagedObjectID {}
@end

@interface _Championship : FootblModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ChampionshipID*)objectID;





@property (nonatomic, strong) NSNumber* active;



@property BOOL activeValue;
- (BOOL)activeValue;
- (void)setActiveValue:(BOOL)value_;

//- (BOOL)validateActive:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* country;



//- (BOOL)validateCountry:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* currentRound;



@property int64_t currentRoundValue;
- (int64_t)currentRoundValue;
- (void)setCurrentRoundValue:(int64_t)value_;

//- (BOOL)validateCurrentRound:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* edition;



@property int64_t editionValue;
- (int64_t)editionValue;
- (void)setEditionValue:(int64_t)value_;

//- (BOOL)validateEdition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* roundFinished;



@property BOOL roundFinishedValue;
- (BOOL)roundFinishedValue;
- (void)setRoundFinishedValue:(BOOL)value_;

//- (BOOL)validateRoundFinished:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* rounds;



@property int64_t roundsValue;
- (int64_t)roundsValue;
- (void)setRoundsValue:(int64_t)value_;

//- (BOOL)validateRounds:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *competitors;

- (NSMutableSet*)competitorsSet;




@property (nonatomic, strong) Group *defaultGroup;

//- (BOOL)validateDefaultGroup:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *groups;

- (NSMutableSet*)groupsSet;




@property (nonatomic, strong) NSSet *matches;

- (NSMutableSet*)matchesSet;




@property (nonatomic, strong) Wallet *wallet;

//- (BOOL)validateWallet:(id*)value_ error:(NSError**)error_;





@end

@interface _Championship (CoreDataGeneratedAccessors)

- (void)addCompetitors:(NSSet*)value_;
- (void)removeCompetitors:(NSSet*)value_;
- (void)addCompetitorsObject:(Team*)value_;
- (void)removeCompetitorsObject:(Team*)value_;

- (void)addGroups:(NSSet*)value_;
- (void)removeGroups:(NSSet*)value_;
- (void)addGroupsObject:(Group*)value_;
- (void)removeGroupsObject:(Group*)value_;

- (void)addMatches:(NSSet*)value_;
- (void)removeMatches:(NSSet*)value_;
- (void)addMatchesObject:(Match*)value_;
- (void)removeMatchesObject:(Match*)value_;

@end

@interface _Championship (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveActive;
- (void)setPrimitiveActive:(NSNumber*)value;

- (BOOL)primitiveActiveValue;
- (void)setPrimitiveActiveValue:(BOOL)value_;




- (NSString*)primitiveCountry;
- (void)setPrimitiveCountry:(NSString*)value;




- (NSNumber*)primitiveCurrentRound;
- (void)setPrimitiveCurrentRound:(NSNumber*)value;

- (int64_t)primitiveCurrentRoundValue;
- (void)setPrimitiveCurrentRoundValue:(int64_t)value_;




- (NSNumber*)primitiveEdition;
- (void)setPrimitiveEdition:(NSNumber*)value;

- (int64_t)primitiveEditionValue;
- (void)setPrimitiveEditionValue:(int64_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveRoundFinished;
- (void)setPrimitiveRoundFinished:(NSNumber*)value;

- (BOOL)primitiveRoundFinishedValue;
- (void)setPrimitiveRoundFinishedValue:(BOOL)value_;




- (NSNumber*)primitiveRounds;
- (void)setPrimitiveRounds:(NSNumber*)value;

- (int64_t)primitiveRoundsValue;
- (void)setPrimitiveRoundsValue:(int64_t)value_;





- (NSMutableSet*)primitiveCompetitors;
- (void)setPrimitiveCompetitors:(NSMutableSet*)value;



- (Group*)primitiveDefaultGroup;
- (void)setPrimitiveDefaultGroup:(Group*)value;



- (NSMutableSet*)primitiveGroups;
- (void)setPrimitiveGroups:(NSMutableSet*)value;



- (NSMutableSet*)primitiveMatches;
- (void)setPrimitiveMatches:(NSMutableSet*)value;



- (Wallet*)primitiveWallet;
- (void)setPrimitiveWallet:(Wallet*)value;


@end
