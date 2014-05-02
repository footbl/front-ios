// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Group.h instead.

#import <CoreData/CoreData.h>
#import "FootblModel.h"

extern const struct GroupAttributes {
	__unsafe_unretained NSString *freeToEdit;
	__unsafe_unretained NSString *name;
} GroupAttributes;

extern const struct GroupRelationships {
	__unsafe_unretained NSString *championship;
	__unsafe_unretained NSString *members;
	__unsafe_unretained NSString *owner;
} GroupRelationships;

extern const struct GroupFetchedProperties {
} GroupFetchedProperties;

@class Championship;
@class Membership;
@class User;




@interface GroupID : NSManagedObjectID {}
@end

@interface _Group : FootblModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (GroupID*)objectID;





@property (nonatomic, strong) NSNumber* freeToEdit;



@property BOOL freeToEditValue;
- (BOOL)freeToEditValue;
- (void)setFreeToEditValue:(BOOL)value_;

//- (BOOL)validateFreeToEdit:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Championship *championship;

//- (BOOL)validateChampionship:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *members;

- (NSMutableSet*)membersSet;




@property (nonatomic, strong) User *owner;

//- (BOOL)validateOwner:(id*)value_ error:(NSError**)error_;





@end

@interface _Group (CoreDataGeneratedAccessors)

- (void)addMembers:(NSSet*)value_;
- (void)removeMembers:(NSSet*)value_;
- (void)addMembersObject:(Membership*)value_;
- (void)removeMembersObject:(Membership*)value_;

@end

@interface _Group (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveFreeToEdit;
- (void)setPrimitiveFreeToEdit:(NSNumber*)value;

- (BOOL)primitiveFreeToEditValue;
- (void)setPrimitiveFreeToEditValue:(BOOL)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (Championship*)primitiveChampionship;
- (void)setPrimitiveChampionship:(Championship*)value;



- (NSMutableSet*)primitiveMembers;
- (void)setPrimitiveMembers:(NSMutableSet*)value;



- (User*)primitiveOwner;
- (void)setPrimitiveOwner:(User*)value;


@end
