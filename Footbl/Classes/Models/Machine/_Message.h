// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Message.h instead.

#import <CoreData/CoreData.h>
#import "FTModel.h"

extern const struct MessageAttributes {
	__unsafe_unretained NSString *deliveryFailed;
	__unsafe_unretained NSString *message;
	__unsafe_unretained NSString *typeString;
} MessageAttributes;

extern const struct MessageRelationships {
	__unsafe_unretained NSString *group;
	__unsafe_unretained NSString *user;
} MessageRelationships;

@class Group;
@class User;

@interface MessageID : FTModelID {}
@end

@interface _Message : FTModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MessageID* objectID;

@property (nonatomic, strong) NSNumber* deliveryFailed;

@property (atomic) BOOL deliveryFailedValue;
- (BOOL)deliveryFailedValue;
- (void)setDeliveryFailedValue:(BOOL)value_;

//- (BOOL)validateDeliveryFailed:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* message;

//- (BOOL)validateMessage:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* typeString;

//- (BOOL)validateTypeString:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Group *group;

//- (BOOL)validateGroup:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) User *user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;

@end

@interface _Message (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveDeliveryFailed;
- (void)setPrimitiveDeliveryFailed:(NSNumber*)value;

- (BOOL)primitiveDeliveryFailedValue;
- (void)setPrimitiveDeliveryFailedValue:(BOOL)value_;

- (NSString*)primitiveMessage;
- (void)setPrimitiveMessage:(NSString*)value;

- (NSString*)primitiveTypeString;
- (void)setPrimitiveTypeString:(NSString*)value;

- (Group*)primitiveGroup;
- (void)setPrimitiveGroup:(Group*)value;

- (User*)primitiveUser;
- (void)setPrimitiveUser:(User*)value;

@end
