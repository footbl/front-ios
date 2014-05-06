// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Championship.h instead.

#import <CoreData/CoreData.h>
#import "FootblModel.h"

extern const struct ChampionshipAttributes {
	__unsafe_unretained NSString *country;
	__unsafe_unretained NSString *currentRound;
	__unsafe_unretained NSString *edition;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *rounds;
} ChampionshipAttributes;

extern const struct ChampionshipRelationships {
	__unsafe_unretained NSString *competitors;
	__unsafe_unretained NSString *groups;
	__unsafe_unretained NSString *matches;
	__unsafe_unretained NSString *wallet;
} ChampionshipRelationships;

extern const struct ChampionshipFetchedProperties {
} ChampionshipFetchedProperties;

@class Team;
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





@property (nonatomic, strong) NSString* country;



//- (BOOL)validateCountry:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* currentRound;



@property int16_t currentRoundValue;
- (int16_t)currentRoundValue;
- (void)setCurrentRoundValue:(int16_t)value_;

//- (BOOL)validateCurrentRound:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* edition;



@property int16_t editionValue;
- (int16_t)editionValue;
- (void)setEditionValue:(int16_t)value_;

//- (BOOL)validateEdition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* rounds;



@property int16_t roundsValue;
- (int16_t)roundsValue;
- (void)setRoundsValue:(int16_t)value_;

//- (BOOL)validateRounds:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *competitors;

- (NSMutableSet*)competitorsSet;




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


- (NSString*)primitiveCountry;
- (void)setPrimitiveCountry:(NSString*)value;




- (NSNumber*)primitiveCurrentRound;
- (void)setPrimitiveCurrentRound:(NSNumber*)value;

- (int16_t)primitiveCurrentRoundValue;
- (void)setPrimitiveCurrentRoundValue:(int16_t)value_;




- (NSNumber*)primitiveEdition;
- (void)setPrimitiveEdition:(NSNumber*)value;

- (int16_t)primitiveEditionValue;
- (void)setPrimitiveEditionValue:(int16_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveRounds;
- (void)setPrimitiveRounds:(NSNumber*)value;

- (int16_t)primitiveRoundsValue;
- (void)setPrimitiveRoundsValue:(int16_t)value_;





- (NSMutableSet*)primitiveCompetitors;
- (void)setPrimitiveCompetitors:(NSMutableSet*)value;



- (NSMutableSet*)primitiveGroups;
- (void)setPrimitiveGroups:(NSMutableSet*)value;



- (NSMutableSet*)primitiveMatches;
- (void)setPrimitiveMatches:(NSMutableSet*)value;



- (Wallet*)primitiveWallet;
- (void)setPrimitiveWallet:(Wallet*)value;


@end
