// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CreditRequest.h instead.

#import <CoreData/CoreData.h>
#import "FTModel.h"

extern const struct CreditRequestAttributes {
	__unsafe_unretained NSString *payed;
	__unsafe_unretained NSString *value;
} CreditRequestAttributes;

extern const struct CreditRequestRelationships {
	__unsafe_unretained NSString *chargedUser;
	__unsafe_unretained NSString *creditedUser;
} CreditRequestRelationships;

extern const struct CreditRequestFetchedProperties {
} CreditRequestFetchedProperties;

@class User;
@class User;




@interface CreditRequestID : NSManagedObjectID {}
@end

@interface _CreditRequest : FTModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CreditRequestID*)objectID;





@property (nonatomic, strong) NSNumber* payed;



@property BOOL payedValue;
- (BOOL)payedValue;
- (void)setPayedValue:(BOOL)value_;

//- (BOOL)validatePayed:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* value;



@property int64_t valueValue;
- (int64_t)valueValue;
- (void)setValueValue:(int64_t)value_;

//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) User *chargedUser;

//- (BOOL)validateChargedUser:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) User *creditedUser;

//- (BOOL)validateCreditedUser:(id*)value_ error:(NSError**)error_;





@end

@interface _CreditRequest (CoreDataGeneratedAccessors)

@end

@interface _CreditRequest (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitivePayed;
- (void)setPrimitivePayed:(NSNumber*)value;

- (BOOL)primitivePayedValue;
- (void)setPrimitivePayedValue:(BOOL)value_;




- (NSNumber*)primitiveValue;
- (void)setPrimitiveValue:(NSNumber*)value;

- (int64_t)primitiveValueValue;
- (void)setPrimitiveValueValue:(int64_t)value_;





- (User*)primitiveChargedUser;
- (void)setPrimitiveChargedUser:(User*)value;



- (User*)primitiveCreditedUser;
- (void)setPrimitiveCreditedUser:(User*)value;


@end
