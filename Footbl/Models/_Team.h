// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Team.h instead.

#import <CoreData/CoreData.h>
#import "FootblModel.h"

extern const struct TeamAttributes {
	__unsafe_unretained NSString *acronym;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *picture;
} TeamAttributes;

extern const struct TeamRelationships {
	__unsafe_unretained NSString *guestMatches;
	__unsafe_unretained NSString *hostMatches;
} TeamRelationships;

extern const struct TeamFetchedProperties {
} TeamFetchedProperties;

@class Match;
@class Match;





@interface TeamID : NSManagedObjectID {}
@end

@interface _Team : FootblModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TeamID*)objectID;





@property (nonatomic, strong) NSString* acronym;



//- (BOOL)validateAcronym:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* picture;



//- (BOOL)validatePicture:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *guestMatches;

- (NSMutableSet*)guestMatchesSet;




@property (nonatomic, strong) NSSet *hostMatches;

- (NSMutableSet*)hostMatchesSet;





@end

@interface _Team (CoreDataGeneratedAccessors)

- (void)addGuestMatches:(NSSet*)value_;
- (void)removeGuestMatches:(NSSet*)value_;
- (void)addGuestMatchesObject:(Match*)value_;
- (void)removeGuestMatchesObject:(Match*)value_;

- (void)addHostMatches:(NSSet*)value_;
- (void)removeHostMatches:(NSSet*)value_;
- (void)addHostMatchesObject:(Match*)value_;
- (void)removeHostMatchesObject:(Match*)value_;

@end

@interface _Team (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAcronym;
- (void)setPrimitiveAcronym:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitivePicture;
- (void)setPrimitivePicture:(NSString*)value;





- (NSMutableSet*)primitiveGuestMatches;
- (void)setPrimitiveGuestMatches:(NSMutableSet*)value;



- (NSMutableSet*)primitiveHostMatches;
- (void)setPrimitiveHostMatches:(NSMutableSet*)value;


@end
