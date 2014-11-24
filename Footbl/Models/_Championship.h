// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Championship.h instead.

#import <CoreData/CoreData.h>
#import "FTModel.h"

extern const struct ChampionshipAttributes {
	__unsafe_unretained NSString *country;
	__unsafe_unretained NSString *currentRound;
	__unsafe_unretained NSString *displayName;
	__unsafe_unretained NSString *edition;
	__unsafe_unretained NSString *enabled;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *picture;
	__unsafe_unretained NSString *rounds;
	__unsafe_unretained NSString *typeString;
} ChampionshipAttributes;

extern const struct ChampionshipRelationships {
	__unsafe_unretained NSString *entry;
	__unsafe_unretained NSString *matches;
} ChampionshipRelationships;

@class Entry;
@class Match;

@interface ChampionshipID : FTModelID {}
@end

@interface _Championship : FTModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ChampionshipID* objectID;

@property (nonatomic, strong) NSString* country;

//- (BOOL)validateCountry:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* currentRound;

@property (atomic) int64_t currentRoundValue;
- (int64_t)currentRoundValue;
- (void)setCurrentRoundValue:(int64_t)value_;

//- (BOOL)validateCurrentRound:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* displayName;

//- (BOOL)validateDisplayName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* edition;

@property (atomic) int64_t editionValue;
- (int64_t)editionValue;
- (void)setEditionValue:(int64_t)value_;

//- (BOOL)validateEdition:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* enabled;

@property (atomic) BOOL enabledValue;
- (BOOL)enabledValue;
- (void)setEnabledValue:(BOOL)value_;

//- (BOOL)validateEnabled:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* picture;

//- (BOOL)validatePicture:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* rounds;

@property (atomic) int64_t roundsValue;
- (int64_t)roundsValue;
- (void)setRoundsValue:(int64_t)value_;

//- (BOOL)validateRounds:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* typeString;

//- (BOOL)validateTypeString:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Entry *entry;

//- (BOOL)validateEntry:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *matches;

- (NSMutableSet*)matchesSet;

@end

@interface _Championship (MatchesCoreDataGeneratedAccessors)
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

- (int64_t)primitiveCurrentRoundValue;
- (void)setPrimitiveCurrentRoundValue:(int64_t)value_;

- (NSString*)primitiveDisplayName;
- (void)setPrimitiveDisplayName:(NSString*)value;

- (NSNumber*)primitiveEdition;
- (void)setPrimitiveEdition:(NSNumber*)value;

- (int64_t)primitiveEditionValue;
- (void)setPrimitiveEditionValue:(int64_t)value_;

- (NSNumber*)primitiveEnabled;
- (void)setPrimitiveEnabled:(NSNumber*)value;

- (BOOL)primitiveEnabledValue;
- (void)setPrimitiveEnabledValue:(BOOL)value_;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSString*)primitivePicture;
- (void)setPrimitivePicture:(NSString*)value;

- (NSNumber*)primitiveRounds;
- (void)setPrimitiveRounds:(NSNumber*)value;

- (int64_t)primitiveRoundsValue;
- (void)setPrimitiveRoundsValue:(int64_t)value_;

- (NSString*)primitiveTypeString;
- (void)setPrimitiveTypeString:(NSString*)value;

- (Entry*)primitiveEntry;
- (void)setPrimitiveEntry:(Entry*)value;

- (NSMutableSet*)primitiveMatches;
- (void)setPrimitiveMatches:(NSMutableSet*)value;

@end
