// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Team.h instead.

#import <CoreData/CoreData.h>
#import "FootblModel.h"

extern const struct TeamAttributes {
} TeamAttributes;

extern const struct TeamRelationships {
} TeamRelationships;

extern const struct TeamFetchedProperties {
} TeamFetchedProperties;



@interface TeamID : NSManagedObjectID {}
@end

@interface _Team : FootblModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TeamID*)objectID;






@end

@interface _Team (CoreDataGeneratedAccessors)

@end

@interface _Team (CoreDataGeneratedPrimitiveAccessors)


@end
