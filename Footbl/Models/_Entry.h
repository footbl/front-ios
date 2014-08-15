// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Entry.h instead.

#import <CoreData/CoreData.h>
#import "FTModel.h"

extern const struct EntryAttributes {
} EntryAttributes;

extern const struct EntryRelationships {
	__unsafe_unretained NSString *championship;
} EntryRelationships;

extern const struct EntryFetchedProperties {
} EntryFetchedProperties;

@class Championship;


@interface EntryID : NSManagedObjectID {}
@end

@interface _Entry : FTModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (EntryID*)objectID;





@property (nonatomic, strong) Championship *championship;

//- (BOOL)validateChampionship:(id*)value_ error:(NSError**)error_;





@end

@interface _Entry (CoreDataGeneratedAccessors)

@end

@interface _Entry (CoreDataGeneratedPrimitiveAccessors)



- (Championship*)primitiveChampionship;
- (void)setPrimitiveChampionship:(Championship*)value;


@end
