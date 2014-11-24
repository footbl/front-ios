// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.h instead.

#import <CoreData/CoreData.h>
#import "FTModel.h"

extern const struct UserAttributes {
	__unsafe_unretained NSString *about;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *featured;
	__unsafe_unretained NSString *funds;
	__unsafe_unretained NSString *history;
	__unsafe_unretained NSString *isMe;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *numberOfFans;
	__unsafe_unretained NSString *numberOfLeagues;
	__unsafe_unretained NSString *picture;
	__unsafe_unretained NSString *previousRanking;
	__unsafe_unretained NSString *ranking;
	__unsafe_unretained NSString *stake;
	__unsafe_unretained NSString *username;
	__unsafe_unretained NSString *verified;
} UserAttributes;

extern const struct UserRelationships {
	__unsafe_unretained NSString *bets;
	__unsafe_unretained NSString *chargeRequests;
	__unsafe_unretained NSString *creditRequests;
	__unsafe_unretained NSString *fanByUsers;
	__unsafe_unretained NSString *fanOfUsers;
	__unsafe_unretained NSString *memberships;
	__unsafe_unretained NSString *messages;
	__unsafe_unretained NSString *ownedGroups;
	__unsafe_unretained NSString *prizes;
} UserRelationships;

@class Bet;
@class CreditRequest;
@class CreditRequest;
@class User;
@class User;
@class Membership;
@class Message;
@class Group;
@class Prize;

@class NSObject;

@interface UserID : FTModelID {}
@end

@interface _User : FTModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) UserID* objectID;

@property (nonatomic, strong) NSString* about;

//- (BOOL)validateAbout:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* email;

//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* featured;

@property (atomic) BOOL featuredValue;
- (BOOL)featuredValue;
- (void)setFeaturedValue:(BOOL)value_;

//- (BOOL)validateFeatured:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* funds;

@property (atomic) float fundsValue;
- (float)fundsValue;
- (void)setFundsValue:(float)value_;

//- (BOOL)validateFunds:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id history;

//- (BOOL)validateHistory:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isMe;

@property (atomic) BOOL isMeValue;
- (BOOL)isMeValue;
- (void)setIsMeValue:(BOOL)value_;

//- (BOOL)validateIsMe:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* numberOfFans;

@property (atomic) int64_t numberOfFansValue;
- (int64_t)numberOfFansValue;
- (void)setNumberOfFansValue:(int64_t)value_;

//- (BOOL)validateNumberOfFans:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* numberOfLeagues;

@property (atomic) int64_t numberOfLeaguesValue;
- (int64_t)numberOfLeaguesValue;
- (void)setNumberOfLeaguesValue:(int64_t)value_;

//- (BOOL)validateNumberOfLeagues:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* picture;

//- (BOOL)validatePicture:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* previousRanking;

@property (atomic) int64_t previousRankingValue;
- (int64_t)previousRankingValue;
- (void)setPreviousRankingValue:(int64_t)value_;

//- (BOOL)validatePreviousRanking:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* ranking;

@property (atomic) int64_t rankingValue;
- (int64_t)rankingValue;
- (void)setRankingValue:(int64_t)value_;

//- (BOOL)validateRanking:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* stake;

@property (atomic) int64_t stakeValue;
- (int64_t)stakeValue;
- (void)setStakeValue:(int64_t)value_;

//- (BOOL)validateStake:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* username;

//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* verified;

@property (atomic) BOOL verifiedValue;
- (BOOL)verifiedValue;
- (void)setVerifiedValue:(BOOL)value_;

//- (BOOL)validateVerified:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *bets;

- (NSMutableSet*)betsSet;

@property (nonatomic, strong) CreditRequest *chargeRequests;

//- (BOOL)validateChargeRequests:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *creditRequests;

- (NSMutableSet*)creditRequestsSet;

@property (nonatomic, strong) NSSet *fanByUsers;

- (NSMutableSet*)fanByUsersSet;

@property (nonatomic, strong) NSSet *fanOfUsers;

- (NSMutableSet*)fanOfUsersSet;

@property (nonatomic, strong) NSSet *memberships;

- (NSMutableSet*)membershipsSet;

@property (nonatomic, strong) NSSet *messages;

- (NSMutableSet*)messagesSet;

@property (nonatomic, strong) NSSet *ownedGroups;

- (NSMutableSet*)ownedGroupsSet;

@property (nonatomic, strong) NSSet *prizes;

- (NSMutableSet*)prizesSet;

@end

@interface _User (BetsCoreDataGeneratedAccessors)
- (void)addBets:(NSSet*)value_;
- (void)removeBets:(NSSet*)value_;
- (void)addBetsObject:(Bet*)value_;
- (void)removeBetsObject:(Bet*)value_;

@end

@interface _User (CreditRequestsCoreDataGeneratedAccessors)
- (void)addCreditRequests:(NSSet*)value_;
- (void)removeCreditRequests:(NSSet*)value_;
- (void)addCreditRequestsObject:(CreditRequest*)value_;
- (void)removeCreditRequestsObject:(CreditRequest*)value_;

@end

@interface _User (FanByUsersCoreDataGeneratedAccessors)
- (void)addFanByUsers:(NSSet*)value_;
- (void)removeFanByUsers:(NSSet*)value_;
- (void)addFanByUsersObject:(User*)value_;
- (void)removeFanByUsersObject:(User*)value_;

@end

@interface _User (FanOfUsersCoreDataGeneratedAccessors)
- (void)addFanOfUsers:(NSSet*)value_;
- (void)removeFanOfUsers:(NSSet*)value_;
- (void)addFanOfUsersObject:(User*)value_;
- (void)removeFanOfUsersObject:(User*)value_;

@end

@interface _User (MembershipsCoreDataGeneratedAccessors)
- (void)addMemberships:(NSSet*)value_;
- (void)removeMemberships:(NSSet*)value_;
- (void)addMembershipsObject:(Membership*)value_;
- (void)removeMembershipsObject:(Membership*)value_;

@end

@interface _User (MessagesCoreDataGeneratedAccessors)
- (void)addMessages:(NSSet*)value_;
- (void)removeMessages:(NSSet*)value_;
- (void)addMessagesObject:(Message*)value_;
- (void)removeMessagesObject:(Message*)value_;

@end

@interface _User (OwnedGroupsCoreDataGeneratedAccessors)
- (void)addOwnedGroups:(NSSet*)value_;
- (void)removeOwnedGroups:(NSSet*)value_;
- (void)addOwnedGroupsObject:(Group*)value_;
- (void)removeOwnedGroupsObject:(Group*)value_;

@end

@interface _User (PrizesCoreDataGeneratedAccessors)
- (void)addPrizes:(NSSet*)value_;
- (void)removePrizes:(NSSet*)value_;
- (void)addPrizesObject:(Prize*)value_;
- (void)removePrizesObject:(Prize*)value_;

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

- (NSNumber*)primitiveNumberOfFans;
- (void)setPrimitiveNumberOfFans:(NSNumber*)value;

- (int64_t)primitiveNumberOfFansValue;
- (void)setPrimitiveNumberOfFansValue:(int64_t)value_;

- (NSNumber*)primitiveNumberOfLeagues;
- (void)setPrimitiveNumberOfLeagues:(NSNumber*)value;

- (int64_t)primitiveNumberOfLeaguesValue;
- (void)setPrimitiveNumberOfLeaguesValue:(int64_t)value_;

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

- (CreditRequest*)primitiveChargeRequests;
- (void)setPrimitiveChargeRequests:(CreditRequest*)value;

- (NSMutableSet*)primitiveCreditRequests;
- (void)setPrimitiveCreditRequests:(NSMutableSet*)value;

- (NSMutableSet*)primitiveFanByUsers;
- (void)setPrimitiveFanByUsers:(NSMutableSet*)value;

- (NSMutableSet*)primitiveFanOfUsers;
- (void)setPrimitiveFanOfUsers:(NSMutableSet*)value;

- (NSMutableSet*)primitiveMemberships;
- (void)setPrimitiveMemberships:(NSMutableSet*)value;

- (NSMutableSet*)primitiveMessages;
- (void)setPrimitiveMessages:(NSMutableSet*)value;

- (NSMutableSet*)primitiveOwnedGroups;
- (void)setPrimitiveOwnedGroups:(NSMutableSet*)value;

- (NSMutableSet*)primitivePrizes;
- (void)setPrimitivePrizes:(NSMutableSet*)value;

@end
