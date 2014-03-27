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





@property (nonatomic, strong) NSString* rid;



//- (BOOL)validateRid:(id*)value_ error:(NSError**)error_;






@end

@interface _FootblModel (CoreDataGeneratedAccessors)

@end

@interface _FootblModel (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveRid;
- (void)setPrimitiveRid:(NSString*)value;




@end
