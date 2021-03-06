//
//  FTBClient.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/13/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FXKeychain/FXKeychain.h>
#import <SPHipster/SPHipster.h>

#import "FTBClient.h"
#import "FTBBet.h"
#import "FTBChallenge.h"
#import "FTBChampionship.h"
#import "FTBCreditRequest.h"
#import "FTBGroup.h"
#import "FTBMatch.h"
#import "FTBMessage.h"
#import "FTBPrize.h"
#import "FTBSeason.h"
#import "FTBUser.h"
#import "FTImageUploader.h"
#import "NSString+Hex.h"

const NSUInteger FTBClientPageSize                  = 20;
static NSString * const kUserEmailKey               = @"kUserEmailKey";
static NSString * const kUserIdentifierKey          = @"kUserIdentifierKey";
static NSString * const kUserPasswordKey            = @"kUserPasswordKey";
static NSString * const kUserFbAuthenticatedKey     = @"kUserFbAuthenticatedKey";
static NSTimeInterval const kBetSyncDelay           = 3;

typedef void (^FTBBlockSuccess)(NSURLSessionDataTask *, id);
typedef void (^FTBBlockFailure)(NSURLSessionDataTask *, NSError *);

FTBBlockSuccess FTBMakeBlockSuccess(Class modelClass, FTBBlockObject success, FTBBlockError failure) {
	return ^(NSURLSessionDataTask *task, id responseObject) {
		NSError *error = nil;
		id object = nil;
		if ([responseObject isKindOfClass:[NSArray class]]) {
			object = [MTLJSONAdapter modelsOfClass:modelClass fromJSONArray:responseObject error:&error];
		} else if ([responseObject isKindOfClass:[NSDictionary class]]) {
			object = [MTLJSONAdapter modelOfClass:modelClass fromJSONDictionary:responseObject error:&error];
        } else if ([responseObject isKindOfClass:[NSData class]]) {
            object = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		} else {
			object = responseObject;
		}
		
		if (failure && error) {
			failure(error);
		} else if (success) {
			success(object);
		}
	};
}

FTBBlockFailure FTBMakeBlockFailure(NSString *method, NSString *path, NSDictionary *parameters, Class modelClass, FTBBlockObject success, FTBBlockError failure) {
	return ^(NSURLSessionDataTask *task, NSError *error) {
		NSInteger code = ((NSHTTPURLResponse *)task.response).statusCode;
		NSError *newError = [[NSError alloc] initWithDomain:error.domain code:code userInfo:error.userInfo];
		if (failure) failure(newError);
	};
}

@interface FTBClient ()

@property (nonatomic, strong, readwrite) FTBUser *user;

@end

@implementation FTBClient

#pragma mark -

+ (void)load {
	[FXKeychain defaultKeychain][(__bridge id)(kSecAttrAccessible)] = (__bridge id)(kSecAttrAccessibleAlways);
}

+ (instancetype)client {
	static FTBClient *client;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSURL *URL = [NSURL URLWithString:FTBBaseURL];
        
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        
        NSArray *responseSerializers = @[[AFJSONResponseSerializer serializer], [AFHTTPResponseSerializer serializer]];
        AFCompoundResponseSerializer *responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:responseSerializers];
        
        client = [[self alloc] initWithBaseURL:URL];
        client.requestSerializer = requestSerializer;
        client.responseSerializer = responseSerializer;
        
        AFNetworkActivityIndicatorManager *activityIndicatorManager = [AFNetworkActivityIndicatorManager sharedManager];
        activityIndicatorManager.enabled = YES;
		
		NSString *identifier = [FXKeychain defaultKeychain][kUserIdentifierKey];
		NSString *password = [FXKeychain defaultKeychain][kUserPasswordKey];
		if (identifier.length > 0 && password.length > 0) {
			[client.requestSerializer setAuthorizationHeaderFieldWithUsername:identifier password:password];
		}
	});
	return client;
}

- (FTBUser *)user {
	if (!_user) {
		NSString *identifier = [FXKeychain defaultKeychain][kUserIdentifierKey];
		if (identifier.length > 0) {
			_user = [[FTBUser alloc] init];
			_user.identifier = identifier;
			_user.email = [FXKeychain defaultKeychain][kUserEmailKey];
		}
	}
	return _user;
}

#pragma mark -

- (void)GET:(NSString *)path parameters:(NSDictionary *)parameters modelClass:(Class)modelClass
 success:(void (^)(id))success failure:(void (^)(NSError *))failure {
	FTBBlockSuccess blockSuccess = FTBMakeBlockSuccess(modelClass, success, failure);
	FTBBlockFailure blockFailure = FTBMakeBlockFailure(@"GET", path, parameters, modelClass, success, failure);
	[self GET:path parameters:parameters success:blockSuccess failure:blockFailure];
}

- (void)POST:(NSString *)path parameters:(NSDictionary *)parameters modelClass:(Class)modelClass
 success:(void (^)(id))success failure:(void (^)(NSError *))failure {
	FTBBlockSuccess blockSuccess = FTBMakeBlockSuccess(modelClass, success, failure);
	FTBBlockFailure blockFailure = FTBMakeBlockFailure(@"POST", path, parameters, modelClass, success, failure);
	[self POST:path parameters:parameters success:blockSuccess failure:blockFailure];
}

- (void)PUT:(NSString *)path parameters:(NSDictionary *)parameters modelClass:(Class)modelClass
 success:(void (^)(id))success failure:(void (^)(NSError *))failure {
	FTBBlockSuccess blockSuccess = FTBMakeBlockSuccess(modelClass, success, failure);
	FTBBlockFailure blockFailure = FTBMakeBlockFailure(@"PUT", path, parameters, modelClass, success, failure);
	[self PUT:path parameters:parameters success:blockSuccess failure:blockFailure];
}

- (void)DELETE:(NSString *)path parameters:(NSDictionary *)parameters modelClass:(Class)modelClass
 success:(void (^)(id))success failure:(void (^)(NSError *))failure {
	FTBBlockSuccess blockSuccess = FTBMakeBlockSuccess(modelClass, success, failure);
	FTBBlockFailure blockFailure = FTBMakeBlockFailure(@"DELETE", path, parameters, modelClass, success, failure);
	[self DELETE:path parameters:parameters success:blockSuccess failure:blockFailure];
}

#pragma mark - Login

- (BOOL)isValidPassword:(NSString *)password {
	NSString *auth = [self.requestSerializer valueForHTTPHeaderField:@"Authorization"];
	NSString *credentials = [NSString stringWithFormat:@"%@:%@", self.user.identifier, password];
	NSString *base64 = [[credentials dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:kNilOptions];
	return [auth containsString:base64];
}

- (BOOL)isAuthenticated {
	return [self.requestSerializer valueForHTTPHeaderField:@"Authorization"] != nil;
}

- (BOOL)isAnonymous {
	return (self.isAuthenticated && self.user.email.length == 0 && self.user.facebookId.length == 0);
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	__weak typeof(self) this = self;
	[self.requestSerializer setAuthorizationHeaderFieldWithUsername:email password:password];
	[self GET:@"/users/me" parameters:nil modelClass:[FTBUser class] success:^(FTBUser *object) {
		[FXKeychain defaultKeychain][kUserIdentifierKey] = object.identifier;
		[FXKeychain defaultKeychain][kUserPasswordKey] = password;
		[FXKeychain defaultKeychain][kUserEmailKey] = email;
		[this registerForRemoteNotifications];
		[[NSNotificationCenter defaultCenter] postNotificationName:kFTNotificationAuthenticationChanged object:nil];
		if (success) success(object);
	} failure:^(NSError *error) {
		[this.requestSerializer clearAuthorizationHeader];
		if (failure) failure(error);
	}];
}

- (void)logout {
	self.user = nil;
	[self.requestSerializer clearAuthorizationHeader];
	
	[FXKeychain defaultKeychain][kUserFbAuthenticatedKey] = nil;
	[FXKeychain defaultKeychain][kUserIdentifierKey] = nil;
	[FXKeychain defaultKeychain][kUserPasswordKey] = nil;
	[FXKeychain defaultKeychain][kUserEmailKey] = nil;
	
    FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
    [manager logOut];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kFTNotificationAuthenticationChanged object:nil];
}

- (void)registerForRemoteNotifications {
    UIUserNotificationType types = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

#pragma mark - Championship

- (void)championships:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSDictionary *parameters = @{@"page": @(page)};
	[self GET:@"/championships" parameters:parameters modelClass:[FTBChampionship class] success:success failure:failure];
}

- (void)championship:(NSString *)identifier success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/championships/%@", identifier];
	[self GET:path parameters:nil modelClass:[FTBChampionship class] success:success failure:failure];
}

#pragma mark - Credit Request

- (void)approveCreditRequest:(NSString *)request success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/credit-requests/%@/approve", request];
	[self PUT:path parameters:nil modelClass:[FTBCreditRequest class] success:success failure:failure];
}

- (void)createCreditRequest:(NSString *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSDictionary *parameters = @{@"user": user};
	[self POST:@"/credit-requests" parameters:parameters modelClass:[FTBCreditRequest class] success:success failure:failure];
}

- (void)creditRequest:(NSString *)request success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/credit-requests/%@", request];
	[self GET:path parameters:nil modelClass:[FTBCreditRequest class] success:success failure:failure];
}

- (void)creditRequests:(FTBUser *)creditedUser chargedUser:(FTBUser *)chargedUser page:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"page": @(page)}];
	if (creditedUser) parameters[@"filterByCreditedUser"] = creditedUser.identifier;
	if (chargedUser) parameters[@"filterByChargedUser"] = chargedUser.identifier;
	[self GET:@"/credit-requests" parameters:parameters modelClass:[FTBCreditRequest class] success:success failure:failure];
}

- (void)rejectCreditRequest:(FTBCreditRequest *)request success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/credit-requests/%@/reject", request.identifier];
	[self PUT:path parameters:nil modelClass:[FTBCreditRequest class] success:success failure:failure];
}

/*
#pragma mark - Group

- (void)enterGroup:(NSString *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/groups/%@", group];
	[self GET:path parameters:nil modelClass:[FTBGroup class] success:success failure:failure];
}

- (void)createGroup:(NSString *)name pictureURL:(NSURL *)pictureURL success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	parameters[@"name"] = name;
	if (pictureURL) parameters[@"picture"] = pictureURL.absoluteString;
	[self POST:@"/groups" parameters:parameters modelClass:[FTBGroup class] success:success failure:failure];
}

- (void)group:(NSString *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/groups/%@", group];
	[self GET:path parameters:nil modelClass:[FTBGroup class] success:success failure:failure];
}

- (void)inviteUser:(FTBUser *)user toGroup:(FTBGroup *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/groups/%@/invite", group.identifier];
	NSDictionary *parameters = @{@"user": user.identifier};
	[self PUT:path parameters:parameters modelClass:[FTBGroup class] success:success failure:failure];
}

- (void)leaveGroup:(FTBGroup *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/groups/%@/leave", group.identifier];
	[self PUT:path parameters:nil modelClass:[FTBGroup class] success:success failure:failure];
}

- (void)groups:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSDictionary *parameters = @{@"page": @(page)};
	[self GET:@"/groups" parameters:parameters modelClass:[FTBGroup class] success:success failure:failure];
}

- (void)removeGroup:(FTBGroup *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/groups/%@", group.identifier];
	[self DELETE:path parameters:nil modelClass:[FTBGroup class] success:success failure:failure];
}

- (void)updateGroup:(FTBGroup *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/groups/%@", group.identifier];
	NSDictionary *parameters = @{@"name": group.name, @"picture": group.pictureURL.absoluteString};
	[self PUT:path parameters:parameters modelClass:[FTBGroup class] success:success failure:failure];
}

- (void)addInvitedMembers:(NSArray *)members group:(FTBGroup *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure {
#warning Implement chunck invite of members
	if (success) success(nil);
}

- (void)addMembers:(NSArray *)members group:(FTBGroup *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure {
#warning Implement chunck invite of members
	if (success) success(nil);
}
*/

#pragma mark - Match

- (void)match:(NSString *)match success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/matches/%@", match];
	[self GET:path parameters:nil modelClass:[FTBMatch class] success:success failure:failure];
}

- (void)matchesInChampionship:(FTBChampionship *)championship page:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"page": @(page)}];
	if (championship.identifier) parameters[@"filterByChampionship"] = championship.identifier;
	[self GET:@"/matches" parameters:parameters modelClass:[FTBMatch class] success:success failure:failure];
}

#pragma mark - Message

- (void)sendMessage:(NSString *)message type:(NSString *)type room:(NSString *)room success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSDictionary *parameters = @{@"room": room, @"message": message, @"type": type};
	[self POST:@"/messages" parameters:parameters modelClass:[FTBMessage class] success:success failure:failure];
}

- (void)messagesForRoom:(NSString *)room page:(NSUInteger)page unread:(BOOL)unread success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSDictionary *parameters = @{@"filterByRoom": room, @"filterByUnread": @(unread), @"page": @(page)};
	[self GET:@"/messages" parameters:parameters modelClass:[FTBMessage class] success:success failure:failure];
}

- (void)markAllMessagesAsReadInRoom:(NSString *)room success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/messages/all/mark-as-read"];
	NSDictionary *parameters = @{@"room": room};
	[self PUT:path parameters:parameters modelClass:[FTBMessage class] success:success failure:failure];
}

#pragma mark - Prize

- (void)prize:(NSString *)prize success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/prizes/%@", prize];
	[self GET:path parameters:nil modelClass:[FTBPrize class] success:success failure:failure];
}

- (void)prizesForUser:(FTBUser *)user page:(NSUInteger)page unread:(BOOL)unread success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSDictionary *parameters = @{@"filterByUnread": @(unread), @"page": @(page)};
	[self GET:@"/prizes" parameters:parameters modelClass:[FTBPrize class] success:success failure:failure];
}

- (void)markPrizeAsRead:(FTBPrize *)prize success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/prizes/%@/mark-as-read", prize.identifier];
	[self PUT:path parameters:nil modelClass:[FTBPrize class] success:success failure:failure];
}

#pragma mark - Season

- (void)season:(NSString *)season success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/seasons/%@", season];
	[self GET:path parameters:nil modelClass:[FTBSeason class] success:success failure:failure];
}

- (void)seasons:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSDictionary *parameters = @{@"page": @(page)};
	[self GET:@"/seasons" parameters:parameters modelClass:[FTBSeason class] success:success failure:failure];
}

#pragma mark - User

- (void)createUserWithPassword:(NSString *)password success:(FTBBlockObject)success failure:(FTBBlockError)failure {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"password"] = password ?: [NSString randomHexStringWithLength:20];
    parameters[@"country"] = info.subscriberCellularProvider.isoCountryCode.uppercaseString ?: @"BR";
	[self POST:@"/users" parameters:parameters modelClass:[FTBUser class] success:^(NSString *identifier) {
		[FXKeychain defaultKeychain][kUserIdentifierKey] = identifier;
		[FXKeychain defaultKeychain][kUserPasswordKey] = password;
		[self.requestSerializer setAuthorizationHeaderFieldWithUsername:identifier password:password];
        if (success) success(identifier);
	} failure:failure];
}

- (void)followUser:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/follow", user.identifier];
	[self PUT:path parameters:nil modelClass:[FTBUser class] success:success failure:failure];
}

- (void)userFollowers:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/followers", user.identifier];
	[self GET:path parameters:nil modelClass:[FTBUser class] success:success failure:failure];
}

- (void)userFollowing:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/following", user.identifier];
	[self GET:path parameters:nil modelClass:[FTBUser class] success:success failure:failure];
}

- (void)forgotPasswordWithSuccess:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/me/forgot-password"];
	[self GET:path parameters:nil modelClass:[FTBUser class] success:success failure:failure];
}

- (void)me:(FTBBlockObject)success failure:(FTBBlockError)failure {
    [self user:@"me" success:success failure:failure];
}

- (void)user:(NSString *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
    __weak typeof(self) weakSelf = self;
	NSString *path = [NSString stringWithFormat:@"/users/%@", user];
	[self GET:path parameters:nil modelClass:[FTBUser class] success:^(FTBUser *object) {
        if (object.isMe) {
            [weakSelf.user mergeValuesForKeysFromModel:object];
        }

        [self myBets:^(NSArray<FTBBet *> *bets) {
            [self.user addBets:bets];
            if (success) success(object);
        } failure:failure];
	} failure:failure];
}

- (void)usersWithEmails:(NSArray *)emails
			facebookIds:(NSArray *)facebookIds
			  usernames:(NSArray *)usernames
                  names:(NSArray *)names
				   page:(NSUInteger)page
				success:(FTBBlockObject)success
				failure:(FTBBlockError)failure {
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	if (emails.count > 0) parameters[@"filterByEmail"] = [emails componentsJoinedByString:@","];
	if (facebookIds.count > 0) parameters[@"facebookIds"] = [facebookIds componentsJoinedByString:@","];
	if (usernames.count > 0) parameters[@"filterByUsername"] = [usernames componentsJoinedByString:@","];
	if (names.count > 0) parameters[@"filterByName"] = [names componentsJoinedByString:@","];
	parameters[@"page"] = @(page);
	[self GET:@"/users" parameters:parameters modelClass:[FTBUser class] success:success failure:failure];
}

- (void)usersWithCountry:(NSString *)country page:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (country.length > 0) parameters[@"filterByCountry"] = country;
    parameters[@"page"] = @(page);
    [self GET:@"/users" parameters:parameters modelClass:[FTBUser class] success:success failure:failure];
}

- (void)users:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"page"] = @(page);
    [self GET:@"/users" parameters:parameters modelClass:[FTBUser class] success:success failure:failure];
}

- (void)rechargeUser:(NSString *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/recharge", user];
	[self PUT:path parameters:nil modelClass:[FTBUser class] success:success failure:failure];
}

- (void)removeUser:(NSString *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@", user];
	[self DELETE:path parameters:nil modelClass:[FTBUser class] success:success failure:failure];
}

- (void)unfollowUser:(NSString *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/unfollow", user];
	[self PUT:path parameters:nil modelClass:[FTBUser class] success:success failure:failure];
}

- (void)updateUserWithParameters:(NSDictionary *)parameters success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@", self.user.identifier];
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:parameters];
	dictionary[@"language"] = [NSLocale preferredLanguages][0];
	dictionary[@"locale"] = [[NSLocale currentLocale] localeIdentifier];
	dictionary[@"timezone"] = [[NSTimeZone defaultTimeZone] name];
	[self PUT:path parameters:dictionary modelClass:[FTBUser class] success:success failure:failure];
}

- (void)updateUsername:(NSString *)username name:(NSString *)name email:(NSString *)email password:(NSString *)password fbToken:(NSString *)fbToken apnsToken:(NSString *)apnsToken image:(UIImage *)image about:(NSString *)about success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	
	void(^block)(NSString *) = ^(NSString *imagePath) {
		NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        parameters[@"username"] = username ?: self.user.username;
        parameters[@"email"] = email ?: self.user.email;
        parameters[@"name"] = name ?: self.user.name;
        parameters[@"about"] = about ?: self.user.about;
        parameters[@"picture"] = imagePath ?: self.user.pictureURL.absoluteString;
        parameters[@"apnsToken"] = apnsToken ?: self.user.apnsToken;
        if (password) parameters[@"password"] = password;
		if (fbToken) [self.requestSerializer setValue:fbToken forHTTPHeaderField:@"facebook-token"];
        
		[self updateUserWithParameters:parameters success:^(id object) {
			[self.requestSerializer setValue:nil forHTTPHeaderField:@"facebook-token"];
			if (success) success(object);
		} failure:^(NSError *error) {
			[self.requestSerializer setValue:nil forHTTPHeaderField:@"facebook-token"];
			if (failure) failure(error);
		}];
	};
	
	[FTImageUploader uploadImage:image withSuccess:^(id object) {
		block(object);
	} failure:^(NSError *error) {
		block(nil);
	}];
}

- (void)featuredUsers:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure {
    NSDictionary *parameters = @{@"filterByFeatured": @YES, @"page":@(page)};
    [self GET:@"/users" parameters:parameters modelClass:[FTBUser class] success:success failure:failure];
}

#pragma mark - Bet

- (void)betInMatch:(FTBMatch *)match bid:(NSNumber *)bid result:(FTBMatchResult)result success:(FTBBlockObject)success failure:(FTBBlockError)failure {
    FTBBet *bet = [[FTBBet alloc] init];
    bet.match = match;
    bet.result = result;
    bet.bid = bid;
    [self.user addBet:bet];
    
    if (match.betBlockKey != 0) {
        cancel_block(match.betBlockKey);
    }
    
    NSUInteger key = 0;
    perform_block_after_delay_k(kBetSyncDelay, &key, ^{
        __weak typeof(self) weakSelf = self;
        NSString *resultString = [[FTBMatch resultJSONTransformer] reverseTransformedValue:@(result)];
        NSDictionary *parameters = @{@"match": match.identifier, @"bid": bid, @"result": resultString};
        [self POST:@"/bets" parameters:parameters modelClass:[FTBBet class] success:^(id object) {
            [weakSelf betsForUser:weakSelf.user match:match activeOnly:NO page:0 success:^(NSArray<FTBBet*> *bets) {
                bet.identifier = bets.firstObject.identifier;
                if (success) success(bet);
            } failure:failure];
        } failure:^(NSError *error) {
            [weakSelf.user removeBet:bet];
            if (failure) failure(error);
        }];
    });
    
    match.betBlockKey = key;
}

- (void)bet:(NSString *)bet success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/bets/%@", bet];
	[self GET:path parameters:nil modelClass:[FTBBet class] success:success failure:failure];
}

- (void)betsForUser:(FTBUser *)user match:(FTBMatch *)match activeOnly:(BOOL)active page:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"page": @(page)}];
	if (match.identifier) parameters[@"filterByMatch"] = match.identifier;
	if (user.identifier) parameters[@"filterByUser"] = user.identifier;
    if (active) parameters[@"filterByNotEmpty"] = @YES;
	[self GET:@"/bets" parameters:parameters modelClass:[FTBBet class] success:success failure:failure];
}

- (void)myBets:(FTBBlockObject)success failure:(FTBBlockError)failure {
    __block NSUInteger page = 0;
    __block NSMutableSet<FTBBet *> *myBets = [[NSMutableSet alloc] init];
    FTBBlockObject successBlock = ^(NSArray<FTBBet *> *bets) {
        [myBets addObjectsFromArray:bets];
        if (bets.count < FTBClientPageSize) {
            if (success) success(myBets);
        } else {
            page += 1;
            [self betsForUser:self.user match:nil activeOnly:NO page:page success:successBlock failure:failure];
        }
    };

    [self betsForUser:self.user match:nil activeOnly:NO page:0 success:successBlock failure:failure];
}

- (void)updateBet:(FTBBet *)bet match:(FTBMatch *)match success:(FTBBlockObject)success failure:(FTBBlockError)failure {
    FTBBet *oldBet = [self.user betForMatch:match];
    [self.user addBet:bet];
    
    if (match.betBlockKey != 0) {
        cancel_block(match.betBlockKey);
    }
    
    NSUInteger key = 0;
    perform_block_after_delay_k(kBetSyncDelay, &key, ^{
        __weak typeof(self) weakSelf = self;
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        parameters[@"bid"] = bet.bid;
        parameters[@"result"] = [bet.bid isEqualToNumber:@0] ? @"draw" : [[FTBMatch resultJSONTransformer] reverseTransformedValue:@(bet.result)];
        NSString *path = [NSString stringWithFormat:@"/bets/%@", bet.identifier];
        [self PUT:path parameters:parameters modelClass:[FTBBet class] success:success failure:^(NSError *error) {
            [weakSelf.user addBet:oldBet];
            if (failure) failure(error);
        }];
    });
    
    match.betBlockKey = key;
}

#pragma mark - Challenge

- (void)acceptChallenge:(FTBChallenge *)challenge success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/challenges/%@/accept", challenge.identifier];
	[self PUT:path parameters:nil modelClass:[FTBChallenge class] success:success failure:failure];
}

- (void)createChallengeForMatch:(FTBMatch *)match bid:(NSNumber *)bid result:(FTBMatchResult)result user:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
    NSString *resultString = [[FTBMatch resultJSONTransformer] reverseTransformedValue:@(result)];
	NSDictionary *parameters = @{@"match": match.identifier, @"bid": bid, @"result": resultString, @"user": user.identifier};
	[self POST:@"/challenges" parameters:parameters modelClass:[FTBChallenge class] success:success failure:failure];
}

- (void)challenge:(NSString *)challenge success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/challenges/%@", challenge];
	[self GET:path parameters:nil modelClass:[FTBChallenge class] success:success failure:failure];
}

- (void)challengesForChallenger:(FTBUser *)challenger challenged:(FTBUser *)challenged page:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"page": @(page)}];
	if (challenger.identifier) parameters[@"filterByChallenger"] = challenger.identifier;
	if (challenged.identifier) parameters[@"filterByChallenged"] = challenged.identifier;
	[self GET:@"/challenges" parameters:parameters modelClass:[FTBChallenge class] success:success failure:failure];
}

- (void)rejectChallenge:(FTBChallenge *)challenge success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/challenges/%@/reject", challenge.identifier];
	[self GET:path parameters:nil modelClass:[FTBChallenge class] success:success failure:failure];
}

@end
