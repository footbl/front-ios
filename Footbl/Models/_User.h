// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.h instead.

#import <CoreData/CoreData.h>
#import "FootblModel.h"

extern const struct UserAttributes {
	__unsafe_unretained NSString *about;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *picture;
	__unsafe_unretained NSString *username;
	__unsafe_unretained NSString *verified;
} UserAttributes;

extern const struct UserRelationships {
	__unsafe_unretained NSString *comments;
	__unsafe_unretained NSString *memberships;
	__unsafe_unretained NSString *ownedGroups;
	__unsafe_unretained NSString *wallets;
} UserRelationships;

extern const struct UserFetchedProperties {
} UserFetchedProperties;

@class Comment;
@class Membership;
@class Group;
@class Wallet;









@interface UserID : NSManagedObjectID {}
@end

@interface _User : FootblModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (UserID*)objectID;





@property (nonatomic, strong) NSString* about;



//- (BOOL)validateAbout:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* email;



//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* picture;



//- (BOOL)validatePicture:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* username;



//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* verified;



@property BOOL verifiedValue;
- (BOOL)verifiedValue;
- (void)setVerifiedValue:(BOOL)value_;

//- (BOOL)validateVerified:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *comments;

- (NSMutableSet*)commentsSet;




@property (nonatomic, strong) NSSet *memberships;

- (NSMutableSet*)membershipsSet;




@property (nonatomic, strong) NSSet *ownedGroups;

- (NSMutableSet*)ownedGroupsSet;




@property (nonatomic, strong) NSSet *wallets;

- (NSMutableSet*)walletsSet;





@end

@interface _User (CoreDataGeneratedAccessors)

- (void)addComments:(NSSet*)value_;
- (void)removeComments:(NSSet*)value_;
- (void)addCommentsObject:(Comment*)value_;
- (void)removeCommentsObject:(Comment*)value_;

- (void)addMemberships:(NSSet*)value_;
- (void)removeMemberships:(NSSet*)value_;
- (void)addMembershipsObject:(Membership*)value_;
- (void)removeMembershipsObject:(Membership*)value_;

- (void)addOwnedGroups:(NSSet*)value_;
- (void)removeOwnedGroups:(NSSet*)value_;
- (void)addOwnedGroupsObject:(Group*)value_;
- (void)removeOwnedGroupsObject:(Group*)value_;

- (void)addWallets:(NSSet*)value_;
- (void)removeWallets:(NSSet*)value_;
- (void)addWalletsObject:(Wallet*)value_;
- (void)removeWalletsObject:(Wallet*)value_;

@end

@interface _User (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAbout;
- (void)setPrimitiveAbout:(NSString*)value;




- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitivePicture;
- (void)setPrimitivePicture:(NSString*)value;




- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;




- (NSNumber*)primitiveVerified;
- (void)setPrimitiveVerified:(NSNumber*)value;

- (BOOL)primitiveVerifiedValue;
- (void)setPrimitiveVerifiedValue:(BOOL)value_;





- (NSMutableSet*)primitiveComments;
- (void)setPrimitiveComments:(NSMutableSet*)value;



- (NSMutableSet*)primitiveMemberships;
- (void)setPrimitiveMemberships:(NSMutableSet*)value;



- (NSMutableSet*)primitiveOwnedGroups;
- (void)setPrimitiveOwnedGroups:(NSMutableSet*)value;



- (NSMutableSet*)primitiveWallets;
- (void)setPrimitiveWallets:(NSMutableSet*)value;


@end
