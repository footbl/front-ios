// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Match.h instead.

#import <CoreData/CoreData.h>
#import "FootblModel.h"

extern const struct MatchAttributes {
} MatchAttributes;

extern const struct MatchRelationships {
	__unsafe_unretained NSString *championship;
	__unsafe_unretained NSString *comments;
} MatchRelationships;

extern const struct MatchFetchedProperties {
} MatchFetchedProperties;

@class Championship;
@class Comment;


@interface MatchID : NSManagedObjectID {}
@end

@interface _Match : FootblModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MatchID*)objectID;





@property (nonatomic, strong) Championship *championship;

//- (BOOL)validateChampionship:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *comments;

- (NSMutableSet*)commentsSet;





@end

@interface _Match (CoreDataGeneratedAccessors)

- (void)addComments:(NSSet*)value_;
- (void)removeComments:(NSSet*)value_;
- (void)addCommentsObject:(Comment*)value_;
- (void)removeCommentsObject:(Comment*)value_;

@end

@interface _Match (CoreDataGeneratedPrimitiveAccessors)



- (Championship*)primitiveChampionship;
- (void)setPrimitiveChampionship:(Championship*)value;



- (NSMutableSet*)primitiveComments;
- (void)setPrimitiveComments:(NSMutableSet*)value;


@end
