// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Comment.h instead.

#import <CoreData/CoreData.h>
#import "FootblModel.h"

extern const struct CommentAttributes {
} CommentAttributes;

extern const struct CommentRelationships {
	__unsafe_unretained NSString *match;
} CommentRelationships;

extern const struct CommentFetchedProperties {
} CommentFetchedProperties;

@class Match;


@interface CommentID : NSManagedObjectID {}
@end

@interface _Comment : FootblModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CommentID*)objectID;





@property (nonatomic, strong) Match *match;

//- (BOOL)validateMatch:(id*)value_ error:(NSError**)error_;





@end

@interface _Comment (CoreDataGeneratedAccessors)

@end

@interface _Comment (CoreDataGeneratedPrimitiveAccessors)



- (Match*)primitiveMatch;
- (void)setPrimitiveMatch:(Match*)value;


@end
