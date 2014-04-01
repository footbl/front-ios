// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Comment.h instead.

#import <CoreData/CoreData.h>
#import "FootblModel.h"

extern const struct CommentAttributes {
	__unsafe_unretained NSString *date;
	__unsafe_unretained NSString *message;
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





@property (nonatomic, strong) NSDate* date;



//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* message;



//- (BOOL)validateMessage:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Match *match;

//- (BOOL)validateMatch:(id*)value_ error:(NSError**)error_;





@end

@interface _Comment (CoreDataGeneratedAccessors)

@end

@interface _Comment (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;




- (NSString*)primitiveMessage;
- (void)setPrimitiveMessage:(NSString*)value;





- (Match*)primitiveMatch;
- (void)setPrimitiveMatch:(Match*)value;


@end
