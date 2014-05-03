// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Match.h instead.

#import <CoreData/CoreData.h>
#import "FootblModel.h"

extern const struct MatchAttributes {
	__unsafe_unretained NSString *date;
	__unsafe_unretained NSString *elapsed;
	__unsafe_unretained NSString *finished;
	__unsafe_unretained NSString *guestScore;
	__unsafe_unretained NSString *hostScore;
	__unsafe_unretained NSString *localUpdatedAt;
	__unsafe_unretained NSString *potDraw;
	__unsafe_unretained NSString *potGuest;
	__unsafe_unretained NSString *potHost;
	__unsafe_unretained NSString *round;
} MatchAttributes;

extern const struct MatchRelationships {
	__unsafe_unretained NSString *bet;
	__unsafe_unretained NSString *championship;
	__unsafe_unretained NSString *comments;
	__unsafe_unretained NSString *guest;
	__unsafe_unretained NSString *host;
} MatchRelationships;

extern const struct MatchFetchedProperties {
} MatchFetchedProperties;

@class Bet;
@class Championship;
@class Comment;
@class Team;
@class Team;












@interface MatchID : NSManagedObjectID {}
@end

@interface _Match : FootblModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MatchID*)objectID;





@property (nonatomic, strong) NSDate* date;



//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* elapsed;



@property int16_t elapsedValue;
- (int16_t)elapsedValue;
- (void)setElapsedValue:(int16_t)value_;

//- (BOOL)validateElapsed:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* finished;



@property BOOL finishedValue;
- (BOOL)finishedValue;
- (void)setFinishedValue:(BOOL)value_;

//- (BOOL)validateFinished:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* guestScore;



@property int16_t guestScoreValue;
- (int16_t)guestScoreValue;
- (void)setGuestScoreValue:(int16_t)value_;

//- (BOOL)validateGuestScore:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* hostScore;



@property int16_t hostScoreValue;
- (int16_t)hostScoreValue;
- (void)setHostScoreValue:(int16_t)value_;

//- (BOOL)validateHostScore:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* localUpdatedAt;



//- (BOOL)validateLocalUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* potDraw;



@property float potDrawValue;
- (float)potDrawValue;
- (void)setPotDrawValue:(float)value_;

//- (BOOL)validatePotDraw:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* potGuest;



@property float potGuestValue;
- (float)potGuestValue;
- (void)setPotGuestValue:(float)value_;

//- (BOOL)validatePotGuest:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* potHost;



@property float potHostValue;
- (float)potHostValue;
- (void)setPotHostValue:(float)value_;

//- (BOOL)validatePotHost:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* round;



@property int16_t roundValue;
- (int16_t)roundValue;
- (void)setRoundValue:(int16_t)value_;

//- (BOOL)validateRound:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Bet *bet;

//- (BOOL)validateBet:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) Championship *championship;

//- (BOOL)validateChampionship:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *comments;

- (NSMutableSet*)commentsSet;




@property (nonatomic, strong) Team *guest;

//- (BOOL)validateGuest:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) Team *host;

//- (BOOL)validateHost:(id*)value_ error:(NSError**)error_;





@end

@interface _Match (CoreDataGeneratedAccessors)

- (void)addComments:(NSSet*)value_;
- (void)removeComments:(NSSet*)value_;
- (void)addCommentsObject:(Comment*)value_;
- (void)removeCommentsObject:(Comment*)value_;

@end

@interface _Match (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;




- (NSNumber*)primitiveElapsed;
- (void)setPrimitiveElapsed:(NSNumber*)value;

- (int16_t)primitiveElapsedValue;
- (void)setPrimitiveElapsedValue:(int16_t)value_;




- (NSNumber*)primitiveFinished;
- (void)setPrimitiveFinished:(NSNumber*)value;

- (BOOL)primitiveFinishedValue;
- (void)setPrimitiveFinishedValue:(BOOL)value_;




- (NSNumber*)primitiveGuestScore;
- (void)setPrimitiveGuestScore:(NSNumber*)value;

- (int16_t)primitiveGuestScoreValue;
- (void)setPrimitiveGuestScoreValue:(int16_t)value_;




- (NSNumber*)primitiveHostScore;
- (void)setPrimitiveHostScore:(NSNumber*)value;

- (int16_t)primitiveHostScoreValue;
- (void)setPrimitiveHostScoreValue:(int16_t)value_;




- (NSDate*)primitiveLocalUpdatedAt;
- (void)setPrimitiveLocalUpdatedAt:(NSDate*)value;




- (NSNumber*)primitivePotDraw;
- (void)setPrimitivePotDraw:(NSNumber*)value;

- (float)primitivePotDrawValue;
- (void)setPrimitivePotDrawValue:(float)value_;




- (NSNumber*)primitivePotGuest;
- (void)setPrimitivePotGuest:(NSNumber*)value;

- (float)primitivePotGuestValue;
- (void)setPrimitivePotGuestValue:(float)value_;




- (NSNumber*)primitivePotHost;
- (void)setPrimitivePotHost:(NSNumber*)value;

- (float)primitivePotHostValue;
- (void)setPrimitivePotHostValue:(float)value_;




- (NSNumber*)primitiveRound;
- (void)setPrimitiveRound:(NSNumber*)value;

- (int16_t)primitiveRoundValue;
- (void)setPrimitiveRoundValue:(int16_t)value_;





- (Bet*)primitiveBet;
- (void)setPrimitiveBet:(Bet*)value;



- (Championship*)primitiveChampionship;
- (void)setPrimitiveChampionship:(Championship*)value;



- (NSMutableSet*)primitiveComments;
- (void)setPrimitiveComments:(NSMutableSet*)value;



- (Team*)primitiveGuest;
- (void)setPrimitiveGuest:(Team*)value;



- (Team*)primitiveHost;
- (void)setPrimitiveHost:(Team*)value;


@end
