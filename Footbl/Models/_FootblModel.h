// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FootblModel.h instead.

#import <CoreData/CoreData.h>


extern const struct FootblModelAttributes {
	__unsafe_unretained NSString *rid;
} FootblModelAttributes;

extern const struct FootblModelRelationships {
} FootblModelRelationships;

extern const struct FootblModelFetchedProperties {
} FootblModelFetchedProperties;




@interface FootblModelID : NSManagedObjectID {}
@end

@interface _FootblModel : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (FootblModelID*)objectID;





@property (nonatomic, strong) NSNumber* rid;



@property int64_t ridValue;
- (int64_t)ridValue;
- (void)setRidValue:(int64_t)value_;

//- (BOOL)validateRid:(id*)value_ error:(NSError**)error_;






@end

@interface _FootblModel (CoreDataGeneratedAccessors)

@end

@interface _FootblModel (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveRid;
- (void)setPrimitiveRid:(NSNumber*)value;

- (int64_t)primitiveRidValue;
- (void)setPrimitiveRidValue:(int64_t)value_;




@end
