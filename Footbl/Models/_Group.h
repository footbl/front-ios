// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Group.h instead.

#import <CoreData/CoreData.h>
#import "FTModel.h"

extern const struct GroupAttributes {
	__unsafe_unretained NSString *freeToEdit;
	__unsafe_unretained NSString *isDefault;
	__unsafe_unretained NSString *isNew;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *picture;
	__unsafe_unretained NSString *removed;
} GroupAttributes;

extern const struct GroupRelationships {
	__unsafe_unretained NSString *members;
	__unsafe_unretained NSString *owner;
} GroupRelationships;

extern const struct GroupFetchedProperties {
} GroupFetchedProperties;

@class Membership;
@class User;








@interface GroupID : NSManagedObjectID {}
@end

@interface _Group : FTModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (GroupID*)objectID;





@property (nonatomic, strong) NSNumber* freeToEdit;



@property BOOL freeToEditValue;
- (BOOL)freeToEditValue;
- (void)setFreeToEditValue:(BOOL)value_;

//- (BOOL)validateFreeToEdit:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isDefault;



@property BOOL isDefaultValue;
- (BOOL)isDefaultValue;
- (void)setIsDefaultValue:(BOOL)value_;

//- (BOOL)validateIsDefault:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isNew;



@property BOOL isNewValue;
- (BOOL)isNewValue;
- (void)setIsNewValue:(BOOL)value_;

//- (BOOL)validateIsNew:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* picture;



//- (BOOL)validatePicture:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* removed;



@property BOOL removedValue;
- (BOOL)removedValue;
- (void)setRemovedValue:(BOOL)value_;

//- (BOOL)validateRemoved:(id*)value_ error:(NSError**)error_;





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




- (NSNumber*)primitiveIsDefault;
- (void)setPrimitiveIsDefault:(NSNumber*)value;

- (BOOL)primitiveIsDefaultValue;
- (void)setPrimitiveIsDefaultValue:(BOOL)value_;




- (NSNumber*)primitiveIsNew;
- (void)setPrimitiveIsNew:(NSNumber*)value;

- (BOOL)primitiveIsNewValue;
- (void)setPrimitiveIsNewValue:(BOOL)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitivePicture;
- (void)setPrimitivePicture:(NSString*)value;




- (NSNumber*)primitiveRemoved;
- (void)setPrimitiveRemoved:(NSNumber*)value;

- (BOOL)primitiveRemovedValue;
- (void)setPrimitiveRemovedValue:(BOOL)value_;





- (NSMutableSet*)primitiveMembers;
- (void)setPrimitiveMembers:(NSMutableSet*)value;



- (User*)primitiveOwner;
- (void)setPrimitiveOwner:(User*)value;


@end
