// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FTModel.h instead.

#import <CoreData/CoreData.h>


extern const struct FTModelAttributes {
	__unsafe_unretained NSString *rid;
	__unsafe_unretained NSString *slug;
} FTModelAttributes;

extern const struct FTModelRelationships {
} FTModelRelationships;

extern const struct FTModelFetchedProperties {
} FTModelFetchedProperties;





@interface FTModelID : NSManagedObjectID {}
@end

@interface _FTModel : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (FTModelID*)objectID;





@property (nonatomic, strong) NSString* rid;



//- (BOOL)validateRid:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* slug;



//- (BOOL)validateSlug:(id*)value_ error:(NSError**)error_;






@end

@interface _FTModel (CoreDataGeneratedAccessors)

@end

@interface _FTModel (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveRid;
- (void)setPrimitiveRid:(NSString*)value;




- (NSString*)primitiveSlug;
- (void)setPrimitiveSlug:(NSString*)value;




@end
