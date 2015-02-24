// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Prize.h instead.

#import <CoreData/CoreData.h>
#import "FTModel.h"

extern const struct PrizeAttributes {
	__unsafe_unretained NSString *typeString;
	__unsafe_unretained NSString *value;
} PrizeAttributes;

extern const struct PrizeRelationships {
	__unsafe_unretained NSString *user;
} PrizeRelationships;

@class User;

@interface PrizeID : FTModelID {}
@end

@interface _Prize : FTModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) PrizeID* objectID;

@property (nonatomic, strong) NSString* typeString;

//- (BOOL)validateTypeString:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* value;

@property (atomic) float valueValue;
- (float)valueValue;
- (void)setValueValue:(float)value_;

//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) User *user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;

@end

@interface _Prize (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveTypeString;
- (void)setPrimitiveTypeString:(NSString*)value;

- (NSNumber*)primitiveValue;
- (void)setPrimitiveValue:(NSNumber*)value;

- (float)primitiveValueValue;
- (void)setPrimitiveValueValue:(float)value_;

- (User*)primitiveUser;
- (void)setPrimitiveUser:(User*)value;

@end
