// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Group.h instead.

#import <CoreData/CoreData.h>
#import "FootblModel.h"

extern const struct GroupAttributes {
	__unsafe_unretained NSString *freeToEdit;
	__unsafe_unretained NSString *name;
} GroupAttributes;

extern const struct GroupRelationships {
	__unsafe_unretained NSString *championships;
} GroupRelationships;

extern const struct GroupFetchedProperties {
} GroupFetchedProperties;

@class Championship;




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





@property (nonatomic, strong) NSSet *championships;

- (NSMutableSet*)championshipsSet;





@end

@interface _Group (CoreDataGeneratedAccessors)

- (void)addChampionships:(NSSet*)value_;
- (void)removeChampionships:(NSSet*)value_;
- (void)addChampionshipsObject:(Championship*)value_;
- (void)removeChampionshipsObject:(Championship*)value_;

@end

@interface _Group (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveFreeToEdit;
- (void)setPrimitiveFreeToEdit:(NSNumber*)value;

- (BOOL)primitiveFreeToEditValue;
- (void)setPrimitiveFreeToEditValue:(BOOL)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (NSMutableSet*)primitiveChampionships;
- (void)setPrimitiveChampionships:(NSMutableSet*)value;


@end
