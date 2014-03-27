// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Championship.h instead.

#import <CoreData/CoreData.h>
#import "FootblModel.h"

extern const struct ChampionshipAttributes {
	__unsafe_unretained NSString *name;
} ChampionshipAttributes;

extern const struct ChampionshipRelationships {
	__unsafe_unretained NSString *competitors;
	__unsafe_unretained NSString *matches;
} ChampionshipRelationships;

extern const struct ChampionshipFetchedProperties {
} ChampionshipFetchedProperties;

@class Team;
@class Match;



@interface ChampionshipID : NSManagedObjectID {}
@end

@interface _Championship : FootblModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ChampionshipID*)objectID;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *competitors;

- (NSMutableSet*)competitorsSet;




@property (nonatomic, strong) NSSet *matches;

- (NSMutableSet*)matchesSet;





@end

@interface _Championship (CoreDataGeneratedAccessors)

- (void)addCompetitors:(NSSet*)value_;
- (void)removeCompetitors:(NSSet*)value_;
- (void)addCompetitorsObject:(Team*)value_;
- (void)removeCompetitorsObject:(Team*)value_;

- (void)addMatches:(NSSet*)value_;
- (void)removeMatches:(NSSet*)value_;
- (void)addMatchesObject:(Match*)value_;
- (void)removeMatchesObject:(Match*)value_;

@end

@interface _Championship (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (NSMutableSet*)primitiveCompetitors;
- (void)setPrimitiveCompetitors:(NSMutableSet*)value;



- (NSMutableSet*)primitiveMatches;
- (void)setPrimitiveMatches:(NSMutableSet*)value;


@end
