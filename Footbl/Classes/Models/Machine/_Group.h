// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Group.h instead.

#import <CoreData/CoreData.h>
#import "FTModel.h"

extern const struct GroupAttributes {
	__unsafe_unretained NSString *freeToEdit;
	__unsafe_unretained NSString *isDefault;
	__unsafe_unretained NSString *isFriends;
	__unsafe_unretained NSString *isNew;
	__unsafe_unretained NSString *isWorld;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *picture;
	__unsafe_unretained NSString *removed;
	__unsafe_unretained NSString *unreadMessagesCount;
} GroupAttributes;

extern const struct GroupRelationships {
	__unsafe_unretained NSString *members;
	__unsafe_unretained NSString *messages;
	__unsafe_unretained NSString *owner;
} GroupRelationships;

@class Membership;
@class Message;
@class User;

@interface GroupID : FTModelID {}
@end

@interface _Group : FTModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) GroupID* objectID;

@property (nonatomic, strong) NSNumber* freeToEdit;

@property (atomic) BOOL freeToEditValue;
- (BOOL)freeToEditValue;
- (void)setFreeToEditValue:(BOOL)value_;

//- (BOOL)validateFreeToEdit:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isDefault;

@property (atomic) BOOL isDefaultValue;
- (BOOL)isDefaultValue;
- (void)setIsDefaultValue:(BOOL)value_;

//- (BOOL)validateIsDefault:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isFriends;

@property (atomic) BOOL isFriendsValue;
- (BOOL)isFriendsValue;
- (void)setIsFriendsValue:(BOOL)value_;

//- (BOOL)validateIsFriends:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isNew;

@property (atomic) BOOL isNewValue;
- (BOOL)isNewValue;
- (void)setIsNewValue:(BOOL)value_;

//- (BOOL)validateIsNew:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isWorld;

@property (atomic) BOOL isWorldValue;
- (BOOL)isWorldValue;
- (void)setIsWorldValue:(BOOL)value_;

//- (BOOL)validateIsWorld:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* picture;

//- (BOOL)validatePicture:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* removed;

@property (atomic) BOOL removedValue;
- (BOOL)removedValue;
- (void)setRemovedValue:(BOOL)value_;

//- (BOOL)validateRemoved:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* unreadMessagesCount;

@property (atomic) int16_t unreadMessagesCountValue;
- (int16_t)unreadMessagesCountValue;
- (void)setUnreadMessagesCountValue:(int16_t)value_;

//- (BOOL)validateUnreadMessagesCount:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *members;

- (NSMutableSet*)membersSet;

@property (nonatomic, strong) NSSet *messages;

- (NSMutableSet*)messagesSet;

@property (nonatomic, strong) User *owner;

//- (BOOL)validateOwner:(id*)value_ error:(NSError**)error_;

@end

@interface _Group (MembersCoreDataGeneratedAccessors)
- (void)addMembers:(NSSet*)value_;
- (void)removeMembers:(NSSet*)value_;
- (void)addMembersObject:(Membership*)value_;
- (void)removeMembersObject:(Membership*)value_;

@end

@interface _Group (MessagesCoreDataGeneratedAccessors)
- (void)addMessages:(NSSet*)value_;
- (void)removeMessages:(NSSet*)value_;
- (void)addMessagesObject:(Message*)value_;
- (void)removeMessagesObject:(Message*)value_;

@end

@interface _Group (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveFreeToEdit;
- (void)setPrimitiveFreeToEdit:(NSNumber*)value;

- (BOOL)primitiveFreeToEditValue;
- (void)setPrimitiveFreeToEditValue:(BOOL)value_;

- (NSNumber*)primitiveIsDefault;
- (void)setPrimitiveIsDefault:(NSNumber*)value;

- (BOOL)primitiveIsDefaultValue;
- (void)setPrimitiveIsDefaultValue:(BOOL)value_;

- (NSNumber*)primitiveIsFriends;
- (void)setPrimitiveIsFriends:(NSNumber*)value;

- (BOOL)primitiveIsFriendsValue;
- (void)setPrimitiveIsFriendsValue:(BOOL)value_;

- (NSNumber*)primitiveIsNew;
- (void)setPrimitiveIsNew:(NSNumber*)value;

- (BOOL)primitiveIsNewValue;
- (void)setPrimitiveIsNewValue:(BOOL)value_;

- (NSNumber*)primitiveIsWorld;
- (void)setPrimitiveIsWorld:(NSNumber*)value;

- (BOOL)primitiveIsWorldValue;
- (void)setPrimitiveIsWorldValue:(BOOL)value_;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSString*)primitivePicture;
- (void)setPrimitivePicture:(NSString*)value;

- (NSNumber*)primitiveRemoved;
- (void)setPrimitiveRemoved:(NSNumber*)value;

- (BOOL)primitiveRemovedValue;
- (void)setPrimitiveRemovedValue:(BOOL)value_;

- (NSNumber*)primitiveUnreadMessagesCount;
- (void)setPrimitiveUnreadMessagesCount:(NSNumber*)value;

- (int16_t)primitiveUnreadMessagesCountValue;
- (void)setPrimitiveUnreadMessagesCountValue:(int16_t)value_;

- (NSMutableSet*)primitiveMembers;
- (void)setPrimitiveMembers:(NSMutableSet*)value;

- (NSMutableSet*)primitiveMessages;
- (void)setPrimitiveMessages:(NSMutableSet*)value;

- (User*)primitiveOwner;
- (void)setPrimitiveOwner:(User*)value;

@end
