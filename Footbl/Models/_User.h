// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.h instead.

#import <CoreData/CoreData.h>
#import "FTModel.h"

extern const struct UserAttributes {
	__unsafe_unretained NSString *about;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *featured;
	__unsafe_unretained NSString *followers;
	__unsafe_unretained NSString *funds;
	__unsafe_unretained NSString *history;
	__unsafe_unretained NSString *isMe;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *picture;
	__unsafe_unretained NSString *previousRanking;
	__unsafe_unretained NSString *ranking;
	__unsafe_unretained NSString *stake;
	__unsafe_unretained NSString *username;
	__unsafe_unretained NSString *verified;
} UserAttributes;

extern const struct UserRelationships {
	__unsafe_unretained NSString *bets;
	__unsafe_unretained NSString *fans;
	__unsafe_unretained NSString *memberships;
	__unsafe_unretained NSString *ownedGroups;
	__unsafe_unretained NSString *starredUsers;
	__unsafe_unretained NSString *wallets;
} UserRelationships;

extern const struct UserFetchedProperties {
} UserFetchedProperties;

@class Bet;
@class User;
@class Membership;
@class Group;
@class User;
@class Wallet;






@class NSObject;









@interface UserID : NSManagedObjectID {}
@end

@interface _User : FTModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (UserID*)objectID;





@property (nonatomic, strong) NSString* about;



//- (BOOL)validateAbout:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* email;



//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* featured;



@property BOOL featuredValue;
- (BOOL)featuredValue;
- (void)setFeaturedValue:(BOOL)value_;

//- (BOOL)validateFeatured:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* followers;



@property int64_t followersValue;
- (int64_t)followersValue;
- (void)setFollowersValue:(int64_t)value_;

//- (BOOL)validateFollowers:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* funds;



@property float fundsValue;
- (float)fundsValue;
- (void)setFundsValue:(float)value_;

//- (BOOL)validateFunds:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id history;



//- (BOOL)validateHistory:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isMe;



@property BOOL isMeValue;
- (BOOL)isMeValue;
- (void)setIsMeValue:(BOOL)value_;

//- (BOOL)validateIsMe:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* picture;



//- (BOOL)validatePicture:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* previousRanking;



@property int64_t previousRankingValue;
- (int64_t)previousRankingValue;
- (void)setPreviousRankingValue:(int64_t)value_;

//- (BOOL)validatePreviousRanking:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* ranking;



@property int64_t rankingValue;
- (int64_t)rankingValue;
- (void)setRankingValue:(int64_t)value_;

//- (BOOL)validateRanking:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* stake;



@property int64_t stakeValue;
- (int64_t)stakeValue;
- (void)setStakeValue:(int64_t)value_;

//- (BOOL)validateStake:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* username;



//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* verified;



@property BOOL verifiedValue;
- (BOOL)verifiedValue;
- (void)setVerifiedValue:(BOOL)value_;

//- (BOOL)validateVerified:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *bets;

- (NSMutableSet*)betsSet;




@property (nonatomic, strong) NSSet *fans;

- (NSMutableSet*)fansSet;




@property (nonatomic, strong) NSSet *memberships;

- (NSMutableSet*)membershipsSet;




@property (nonatomic, strong) NSSet *ownedGroups;

- (NSMutableSet*)ownedGroupsSet;




@property (nonatomic, strong) NSSet *starredUsers;

- (NSMutableSet*)starredUsersSet;




@property (nonatomic, strong) NSSet *wallets;

- (NSMutableSet*)walletsSet;





@end

@interface _User (CoreDataGeneratedAccessors)

- (void)addBets:(NSSet*)value_;
- (void)removeBets:(NSSet*)value_;
- (void)addBetsObject:(Bet*)value_;
- (void)removeBetsObject:(Bet*)value_;

- (void)addFans:(NSSet*)value_;
- (void)removeFans:(NSSet*)value_;
- (void)addFansObject:(User*)value_;
- (void)removeFansObject:(User*)value_;

- (void)addMemberships:(NSSet*)value_;
- (void)removeMemberships:(NSSet*)value_;
- (void)addMembershipsObject:(Membership*)value_;
- (void)removeMembershipsObject:(Membership*)value_;

- (void)addOwnedGroups:(NSSet*)value_;
- (void)removeOwnedGroups:(NSSet*)value_;
- (void)addOwnedGroupsObject:(Group*)value_;
- (void)removeOwnedGroupsObject:(Group*)value_;

- (void)addStarredUsers:(NSSet*)value_;
- (void)removeStarredUsers:(NSSet*)value_;
- (void)addStarredUsersObject:(User*)value_;
- (void)removeStarredUsersObject:(User*)value_;

- (void)addWallets:(NSSet*)value_;
- (void)removeWallets:(NSSet*)value_;
- (void)addWalletsObject:(Wallet*)value_;
- (void)removeWalletsObject:(Wallet*)value_;

@end

@interface _User (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAbout;
- (void)setPrimitiveAbout:(NSString*)value;




- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;




- (NSNumber*)primitiveFeatured;
- (void)setPrimitiveFeatured:(NSNumber*)value;

- (BOOL)primitiveFeaturedValue;
- (void)setPrimitiveFeaturedValue:(BOOL)value_;




- (NSNumber*)primitiveFollowers;
- (void)setPrimitiveFollowers:(NSNumber*)value;

- (int64_t)primitiveFollowersValue;
- (void)setPrimitiveFollowersValue:(int64_t)value_;




- (NSNumber*)primitiveFunds;
- (void)setPrimitiveFunds:(NSNumber*)value;

- (float)primitiveFundsValue;
- (void)setPrimitiveFundsValue:(float)value_;




- (id)primitiveHistory;
- (void)setPrimitiveHistory:(id)value;




- (NSNumber*)primitiveIsMe;
- (void)setPrimitiveIsMe:(NSNumber*)value;

- (BOOL)primitiveIsMeValue;
- (void)setPrimitiveIsMeValue:(BOOL)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitivePicture;
- (void)setPrimitivePicture:(NSString*)value;




- (NSNumber*)primitivePreviousRanking;
- (void)setPrimitivePreviousRanking:(NSNumber*)value;

- (int64_t)primitivePreviousRankingValue;
- (void)setPrimitivePreviousRankingValue:(int64_t)value_;




- (NSNumber*)primitiveRanking;
- (void)setPrimitiveRanking:(NSNumber*)value;

- (int64_t)primitiveRankingValue;
- (void)setPrimitiveRankingValue:(int64_t)value_;




- (NSNumber*)primitiveStake;
- (void)setPrimitiveStake:(NSNumber*)value;

- (int64_t)primitiveStakeValue;
- (void)setPrimitiveStakeValue:(int64_t)value_;




- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;




- (NSNumber*)primitiveVerified;
- (void)setPrimitiveVerified:(NSNumber*)value;

- (BOOL)primitiveVerifiedValue;
- (void)setPrimitiveVerifiedValue:(BOOL)value_;





- (NSMutableSet*)primitiveBets;
- (void)setPrimitiveBets:(NSMutableSet*)value;



- (NSMutableSet*)primitiveFans;
- (void)setPrimitiveFans:(NSMutableSet*)value;



- (NSMutableSet*)primitiveMemberships;
- (void)setPrimitiveMemberships:(NSMutableSet*)value;



- (NSMutableSet*)primitiveOwnedGroups;
- (void)setPrimitiveOwnedGroups:(NSMutableSet*)value;



- (NSMutableSet*)primitiveStarredUsers;
- (void)setPrimitiveStarredUsers:(NSMutableSet*)value;



- (NSMutableSet*)primitiveWallets;
- (void)setPrimitiveWallets:(NSMutableSet*)value;


@end
