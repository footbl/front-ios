//
//  FTBClient.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/13/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBClient.h"
#import "FTBChampionship.h"
#import "FTBCreditRequest.h"
#import "FTBGroup.h"
#import "FTBUser.h"
#import "FTBMatch.h"
#import "FTBMessage.h"
#import "FTBPrize.h"
#import "FTBSeason.h"
#import "FTBBet.h"
#import "FTBChallenge.h"

#import "FTAuthenticationManager.h"
#import "FTRequestSerializer.h"

typedef void (^FTBBlockSuccess)(NSURLSessionDataTask *, id);
typedef void (^FTBBlockFailure)(NSURLSessionDataTask *, NSError *);

@implementation FTBClient

FTBBlockSuccess FTBMakeBlockSuccess(Class modelClass, FTBBlockObject success, FTBBlockError failure) {
	return ^(NSURLSessionDataTask *task, id responseObject) {
		NSError *error = nil;
		id object = nil;
		if ([responseObject isKindOfClass:[NSArray class]]) {
			object = [MTLJSONAdapter modelsOfClass:modelClass fromJSONArray:responseObject error:&error];
		} else if ([responseObject isKindOfClass:[NSDictionary class]]) {
			object = [MTLJSONAdapter modelOfClass:modelClass fromJSONDictionary:responseObject error:&error];
		} else {
			object = responseObject;
		}
		if (failure && error) failure(error);
		if (success && !error) success(object);
	};
}

FTBBlockFailure FTBMakeBlockFailure(NSString *method, NSString *path, NSDictionary *parameters, Class modelClass, FTBBlockObject success, FTBBlockError failure) {
	return ^(NSURLSessionDataTask *task, NSError *error) {
		if (((NSHTTPURLResponse *)task.response).statusCode == 401) {
			[[[FTBClient client] operationQueue] cancelAllOperations];
			[[FTAuthenticationManager sharedManager] ensureAuthenticationWithSuccess:^(id response) {
				if ([method isEqualToString:@"GET"]) {
					[[FTBClient client] GET:path parameters:parameters modelClass:modelClass success:success failure:failure];
				} else if ([method isEqualToString:@"POST"]) {
					[[FTBClient client] POST:path parameters:parameters modelClass:modelClass success:success failure:failure];
				} else if ([method isEqualToString:@"PUT"]) {
					[[FTBClient client] PUT:path parameters:parameters modelClass:modelClass success:success failure:failure];
				} else if ([method isEqualToString:@"DELETE"]) {
					[[FTBClient client] DELETE:path parameters:parameters modelClass:modelClass success:success failure:failure];
				} else {
					if (failure) failure(error);
				}
			} failure:failure];
		} else {
			if (failure) failure(error);
		}
	};
}

#pragma mark -

+ (instancetype)client {
	static FTBClient *client;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSURL *URL = [NSURL URLWithString:FTBBaseURL];
		client = [[FTBClient alloc] initWithBaseURL:URL];
		client.requestSerializer = [FTRequestSerializer serializer];
		client.responseSerializer = [AFJSONResponseSerializer serializer];
	});
	return client;
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

#pragma mark -

+ (FTBUser *)currentUser {
	return nil;
}

#pragma mark - Championship

- (void)championships:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/championships"];
	NSDictionary *parameters = @{@"page": @(page)};
	[self GET:path parameters:parameters modelClass:[FTBChampionship class] success:success failure:failure];
}

- (void)championship:(NSString *)identifier success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/championships/%@", identifier];
	[self GET:path parameters:nil modelClass:[FTBChampionship class] success:success failure:failure];
}

#pragma mark - Credit Request

- (void)approveCreditRequest:(NSString *)request forUser:(NSString *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/credit-requests/%@/approve", user, request];
	[self PUT:path parameters:nil modelClass:[FTBCreditRequest class] success:success failure:failure];
}

- (void)createCreditRequest:(NSString *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/credit-requests", user];
	[self POST:path parameters:nil modelClass:[FTBCreditRequest class] success:success failure:failure];
}

- (void)creditRequest:(NSString *)request forUser:(NSString *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/credit-requests/%@", user, request];
	[self GET:path parameters:nil modelClass:[FTBCreditRequest class] success:success failure:failure];
}

- (void)creditRequests:(NSString *)user page:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/credit-requests", user];
	NSDictionary *parameters = @{@"page": @(page)};
	[self GET:path parameters:parameters modelClass:[FTBCreditRequest class] success:success failure:failure];
}

- (void)requestedCredits:(NSString *)user page:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/requested-credits", user];
	NSDictionary *parameters = @{@"page": @(page)};
	[self GET:path parameters:parameters modelClass:[FTBCreditRequest class] success:success failure:failure];
}

#pragma mark - Group

- (void)enterGroup:(NSString *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/groups/%@", group];
	[self GET:path parameters:nil modelClass:[FTBGroup class] success:success failure:failure];
}

- (void)createGroup:(NSString *)name pictureURL:(NSURL *)pictureURL success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/groups"];
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	parameters[@"name"] = name;
	if (pictureURL) parameters[@"picture"] = pictureURL.absoluteString;
	[self GET:path parameters:parameters modelClass:[FTBGroup class] success:success failure:failure];
}

- (void)group:(NSString *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/groups/%@", group];
	[self GET:path parameters:nil modelClass:[FTBGroup class] success:success failure:failure];
}

- (void)inviteUser:(FTBUser *)user toGroup:(FTBGroup *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/groups/%@/invite", group.identifier];
	NSDictionary *parameters = @{@"user": user.identifier};
	[self POST:path parameters:parameters modelClass:[FTBGroup class] success:success failure:failure];
}

- (void)leaveGroup:(FTBGroup *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/groups/%@/leave", group.identifier];
	[self DELETE:path parameters:nil modelClass:[FTBGroup class] success:success failure:failure];
}

- (void)groups:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/groups"];
	NSDictionary *parameters = @{@"page": @(page)};
	[self GET:path parameters:parameters modelClass:[FTBGroup class] success:success failure:failure];
}

- (void)removeGroup:(FTBGroup *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/groups/%@", group.identifier];
	[self DELETE:path parameters:nil modelClass:[FTBGroup class] success:success failure:failure];
}

- (void)updateGroup:(FTBGroup *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/groups/%@", group.identifier];
	NSDictionary *parameters = @{@"name": group.name, @"picture": group.pictureURL.absoluteString};
	[self DELETE:path parameters:parameters modelClass:[FTBGroup class] success:success failure:failure];
}

- (void)addInvitedMembers:(NSArray *)members group:(FTBGroup *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure {
#warning Implement chunck invite of members
	if (success) success(nil);
}

- (void)addMembers:(NSArray *)members group:(FTBGroup *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure {
#warning Implement chunck invite of members
	if (success) success(nil);
}

- (void)membersForGroup:(FTBGroup *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure {
#warning Implement group members API
	if (success) success(nil);
}

#pragma mark - Match

- (void)match:(NSString *)match championship:(FTBChampionship *)championship success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/championships/%@/matches/%@", championship.identifier, match];
	[self GET:path parameters:nil modelClass:[FTBMatch class] success:success failure:failure];
}

- (void)matchesInChampionship:(FTBChampionship *)championship page:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/championships/%@/matches", championship.identifier];
	NSDictionary *parameters = @{@"page": @(page)};
	[self GET:path parameters:parameters modelClass:[FTBMatch class] success:success failure:failure];
}

#pragma mark - Message

- (void)sendMessage:(NSString *)message type:(NSString *)type room:(NSString *)room success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/rooms/%@/messages", room];
	NSDictionary *parameters = @{@"message": message, @"type": type};
	[self POST:path parameters:parameters modelClass:[FTBMessage class] success:success failure:failure];
}

- (void)messagesForRoom:(NSString *)room page:(NSUInteger)page unread:(BOOL)unread success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/rooms/%@/messages", room];
	NSDictionary *parameters = @{@"page": @(page), @"unreadMessages": @(unread)};
	[self GET:path parameters:parameters modelClass:[FTBMessage class] success:success failure:failure];
}

- (void)markAllMessagesAsReadInRoom:(NSString *)room success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/rooms/%@/messages/all/mark-as-read", room];
	[self PUT:path parameters:nil modelClass:[FTBMessage class] success:success failure:failure];
}

#pragma mark - Prize

- (void)prize:(NSString *)prize forUser:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/prizes/%@", user.identifier, prize];
	[self GET:path parameters:nil modelClass:[FTBPrize class] success:success failure:failure];
}

- (void)prizesForUser:(FTBUser *)user page:(NSUInteger)page unread:(BOOL)unread success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/prizes", user.identifier];
	NSDictionary *parameters = @{@"page": @(page), @"unreadMessages": @(unread)};
	[self GET:path parameters:parameters modelClass:[FTBPrize class] success:success failure:failure];
}

- (void)markPrizeAsRead:(FTBPrize *)prize user:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/prizes/%@/mark-as-read", user.identifier, prize.identifier];
	[self PUT:path parameters:nil modelClass:[FTBPrize class] success:success failure:failure];
}

#pragma mark - Season

- (void)season:(NSString *)season success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/seasons/%@", season];
	[self GET:path parameters:nil modelClass:[FTBSeason class] success:success failure:failure];
}

- (void)seasons:(NSUInteger)page unread:(BOOL)unread success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/seasons"];
	NSDictionary *parameters = @{@"page": @(page)};
	[self GET:path parameters:parameters modelClass:[FTBSeason class] success:success failure:failure];
}

#pragma mark - User

- (void)authWithSuccess:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/me/auth"];
	[self GET:path parameters:nil modelClass:[FTBUser class] success:success failure:failure];
}

- (void)createUserWithPassword:(NSString *)password country:(NSString *)country success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users"];
	NSDictionary *parameters = @{@"password": password, @"country": country};
	[self POST:path parameters:parameters modelClass:[FTBUser class] success:success failure:failure];
}

- (void)followUser:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/follow", user.identifier];
	[self POST:path parameters:nil modelClass:[FTBUser class] success:success failure:failure];
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

- (void)user:(NSString *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@", user];
	[self GET:path parameters:nil modelClass:[FTBUser class] success:success failure:failure];
}

- (void)usersWithEmails:(NSArray *)emails
			facebookIds:(NSArray *)facebookIds
			  usernames:(NSArray *)usernames
				   name:(NSArray *)name
				   page:(NSUInteger)page
				success:(FTBBlockObject)success
				failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users"];
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	if (emails) parameters[@"emails"] = emails;
	if (facebookIds) parameters[@"facebookIds"] = facebookIds;
	if (usernames) parameters[@"usernames"] = usernames;
	if (name) parameters[@"name"] = name;
	parameters[@"page"] = @(page);
	[self GET:path parameters:parameters modelClass:[FTBUser class] success:success failure:failure];
}

- (void)rechargeUser:(NSString *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/recharge", user];
	[self GET:path parameters:nil modelClass:[FTBUser class] success:success failure:failure];
}

- (void)removeUser:(NSString *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@", user];
	[self DELETE:path parameters:nil modelClass:[FTBUser class] success:success failure:failure];
}

- (void)unfollowUser:(NSString *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/unfollow", user];
	[self DELETE:path parameters:nil modelClass:[FTBUser class] success:success failure:failure];
}

- (void)updateUser:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@", user.identifier];
	NSDictionary *parameters = @{@"email": user.email,
								 @"username": user.username,
								 @"name": user.name,
								 @"password": user.password,
								 @"about": user.about,
								 @"picture": user.pictureURL.absoluteString,
								 @"apnsToken": user.apnsToken,
								 @"entries": user.entries};
	[self PUT:path parameters:parameters modelClass:[FTBUser class] success:success failure:failure];
}

- (void)featuredUsers:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure {
#warning Implement featured users API
	if (success) success(nil);
}

#pragma mark - Bet

- (void)betInMatch:(NSString *)match bid:(NSNumber *)bid result:(NSString *)result user:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/bets", user.identifier];
	NSDictionary *parameters = @{@"match": match, @"bid": bid, @"result": result};
	[self POST:path parameters:parameters modelClass:[FTBBet class] success:success failure:failure];
}

- (void)bet:(NSString *)bet user:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/bets/%@", user.identifier, bet];
	[self GET:path parameters:nil modelClass:[FTBBet class] success:success failure:failure];
}

- (void)betsForUser:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/bets", user.identifier];
	[self GET:path parameters:nil modelClass:[FTBBet class] success:success failure:failure];
}

- (void)updateBet:(FTBBet *)bet user:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/bets/%@", user.identifier, bet.identifier];
	NSDictionary *parameters = [MTLJSONAdapter JSONDictionaryFromModel:bet error:nil];
	[self PUT:path parameters:parameters modelClass:[FTBBet class] success:success failure:failure];
}

#pragma mark - Challenge

- (void)acceptChallenge:(FTBChallenge *)challenge user:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/challenges/%@/accept", user.identifier, challenge.identifier];
	[self PUT:path parameters:nil modelClass:[FTBChallenge class] success:success failure:failure];
}

- (void)createChallengeForMatch:(FTBMatch *)match bid:(NSNumber *)bid result:(NSString *)result user:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/challenges", user.identifier];
	NSDictionary *parameters = @{@"match": match, @"bid": bid, @"result": result};
	[self POST:path parameters:parameters modelClass:[FTBChallenge class] success:success failure:failure];
}

- (void)challenge:(NSString *)challenge user:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/challenges/%@", user.identifier, challenge];
	[self GET:path parameters:nil modelClass:[FTBChallenge class] success:success failure:failure];
}

- (void)challengesForUser:(FTBUser *)user page:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/challenges", user.identifier];
	NSDictionary *parameters = @{@"page": @(page)};
	[self GET:path parameters:parameters modelClass:[FTBChallenge class] success:success failure:failure];
}

- (void)rejectChallenge:(FTBChallenge *)challenge user:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/challenges/%@/reject", user.identifier, challenge.identifier];
	[self GET:path parameters:nil modelClass:[FTBChallenge class] success:success failure:failure];
}

@end
