//
//  FTBClient.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/13/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "FTBConstants.h"

@class FTBModel;
@class FTBChampionship;
@class FTBCreditRequest;
@class FTBGroup;
@class FTBUser;
@class FTBMatch;
@class FTBMessage;
@class FTBPrize;
@class FTBSeason;
@class FTBBet;
@class FTBChallenge;

@interface FTBClient : AFHTTPSessionManager

+ (instancetype)client;

#pragma mark - Championship

- (void)championships:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)championship:(NSString *)identifier success:(FTBBlockObject)success failure:(FTBBlockError)failure;

#pragma mark - Credit Request

- (void)approveCreditRequest:(NSString *)request forUser:(NSString *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)createCreditRequest:(NSString *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)creditRequest:(NSString *)request forUser:(NSString *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)creditRequests:(NSString *)user page:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)requestedCredits:(NSString *)user page:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure;

#pragma mark - Group

- (void)enterGroup:(NSString *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)createGroup:(NSString *)name pictureURL:(NSURL *)pictureURL success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)group:(NSString *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)inviteUser:(FTBUser *)user toGroup:(FTBGroup *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)leaveGroup:(FTBGroup *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)groups:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)removeGroup:(FTBGroup *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)updateGroup:(FTBGroup *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure;

- (void)addInvitedMembers:(NSArray *)members group:(FTBGroup *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)addMembers:(NSArray *)members group:(FTBGroup *)group success:(FTBBlockObject)success failure:(FTBBlockError)failure;

#pragma mark - Match

- (void)match:(NSString *)match championship:(FTBChampionship *)championship success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)matchesInChampionship:(FTBChampionship *)championship page:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure;

#pragma mark - Message

- (void)sendMessage:(NSString *)message type:(NSString *)type room:(NSString *)room success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)messagesForRoom:(NSString *)room page:(NSUInteger)page unread:(BOOL)unread success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)markAllMessagesAsReadInRoom:(NSString *)room success:(FTBBlockObject)success failure:(FTBBlockError)failure;

#pragma mark - Prize

- (void)prize:(NSString *)prize forUser:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)prizesForUser:(FTBUser *)user page:(NSUInteger)page unread:(BOOL)unread success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)markPrizeAsRead:(FTBPrize *)prize user:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure;

#pragma mark - Season

- (void)season:(NSString *)season success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)seasons:(NSUInteger)page unread:(BOOL)unread success:(FTBBlockObject)success failure:(FTBBlockError)failure;

#pragma mark - User

- (void)authWithSuccess:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)createUserWithPassword:(NSString *)password country:(NSString *)country success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)followUser:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)userFollowers:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)userFollowing:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)forgotPasswordWithSuccess:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)user:(NSString *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)usersWithEmails:(NSArray *)emails
			facebookIds:(NSArray *)facebookIds
			  usernames:(NSArray *)usernames
				   name:(NSArray *)name
				   page:(NSUInteger)page
				success:(FTBBlockObject)success
				failure:(FTBBlockError)failure;
- (void)rechargeUser:(NSString *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)removeUser:(NSString *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)unfollowUser:(NSString *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)updateUser:(FTBUser *)user
		  username:(NSString *)username
			  name:(NSString *)name
			 email:(NSString *)email
		  password:(NSString *)password
		   fbToken:(NSString *)fbToken
		 apnsToken:(NSString *)apnsToken
		 imagePath:(NSString *)imagePath
			 about:(NSString *)about
		   success:(FTBBlockObject)success
		   failure:(FTBBlockError)failure;
- (void)updateUser:(FTBUser *)user entries:(NSArray *)entries success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)updateUser:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)featuredUsers:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure;

#pragma mark - Bet

- (void)betInMatch:(FTBMatch *)match bid:(NSNumber *)bid result:(FTBMatchResult)result user:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)bet:(NSString *)bet user:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)betsForUser:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)updateBet:(FTBBet *)bet user:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure;

#pragma mark - Challenge

- (void)acceptChallenge:(FTBChallenge *)challenge user:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)createChallengeForMatch:(FTBMatch *)match bid:(NSNumber *)bid result:(NSString *)result user:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)challenge:(NSString *)challenge user:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)challengesForUser:(FTBUser *)user page:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure;
- (void)rejectChallenge:(FTBChallenge *)challenge user:(FTBUser *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure;

@end
