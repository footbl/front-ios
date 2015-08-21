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

FTBBlockFailure FTBMakeBlockFailure(FTBBlockError failure) {
	return ^(NSURLSessionDataTask *task, NSError *error) {
		if (((NSHTTPURLResponse *)task.response).statusCode == 401) {
			// refazer request
		}
		if (failure) failure(error);
	};
}

#pragma mark -

+ (NSURL *)baseURL {
	return [NSURL URLWithString:@"http://localhost"];
}

+ (instancetype)client {
	static FTBClient *client;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		client = [[FTBClient alloc] initWithBaseURL:[self baseURL]];
		client.requestSerializer = [AFJSONRequestSerializer serializer];
		client.responseSerializer = [AFJSONResponseSerializer serializer];
	});
	return client;
}

#pragma mark - 

+ (void)GET:(NSString *)path parameters:(NSDictionary *)parameters modelClass:(Class)modelClass
 success:(void (^)(id))success failure:(void (^)(NSError *))failure {
	FTBBlockSuccess _success = FTBMakeBlockSuccess(modelClass, success, failure);
	FTBBlockFailure _failure = FTBMakeBlockFailure(failure);
	[[self client] GET:path parameters:parameters success:_success failure:_failure];
}

+ (void)POST:(NSString *)path parameters:(NSDictionary *)parameters modelClass:(Class)modelClass
 success:(void (^)(id))success failure:(void (^)(NSError *))failure {
	FTBBlockSuccess blockSuccess = FTBMakeBlockSuccess(modelClass, success, failure);
	FTBBlockFailure blockFailure = FTBMakeBlockFailure(failure);
	[[self client] POST:path parameters:parameters success:blockSuccess failure:blockFailure];
}

+ (void)PUT:(NSString *)path parameters:(NSDictionary *)parameters modelClass:(Class)modelClass
 success:(void (^)(id))success failure:(void (^)(NSError *))failure {
	FTBBlockSuccess blockSuccess = FTBMakeBlockSuccess(modelClass, success, failure);
	FTBBlockFailure blockFailure = FTBMakeBlockFailure(failure);
	[[self client] PUT:path parameters:parameters success:blockSuccess failure:blockFailure];
}

+ (void)DELETE:(NSString *)path parameters:(NSDictionary *)parameters modelClass:(Class)modelClass
 success:(void (^)(id))success failure:(void (^)(NSError *))failure {
	FTBBlockSuccess blockSuccess = FTBMakeBlockSuccess(modelClass, success, failure);
	FTBBlockFailure blockFailure = FTBMakeBlockFailure(failure);
	[[self client] DELETE:path parameters:parameters success:blockSuccess failure:blockFailure];
}

#pragma mark - Championship

+ (void)championships:(NSUInteger)page success:(FTBBlockArray)success failure:(FTBBlockError)failure {
	NSString *path = @"/championships";
	NSDictionary *parameters = @{@"page": @(page)};
	[self GET:path parameters:parameters modelClass:[FTBChampionship class] success:success failure:failure];
}

+ (void)championship:(NSString *)identifier success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/championships/%@", identifier];
	[self GET:path parameters:nil modelClass:[FTBChampionship class] success:success failure:failure];
}

#pragma mark - Credit Request

+ (void)approveCreditRequest:(NSString *)request forUser:(NSString *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/credit-requests/%@/approve", user, request];
	[self PUT:path parameters:nil modelClass:[FTBCreditRequest class] success:success failure:failure];
}

+ (void)createCreditRequest:(NSString *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/credit-requests", user];
	[self POST:path parameters:nil modelClass:[FTBCreditRequest class] success:success failure:failure];
}

+ (void)creditRequest:(NSString *)request forUser:(NSString *)user success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/credit-requests/%@", user, request];
	[self GET:path parameters:nil modelClass:[FTBCreditRequest class] success:success failure:failure];
}

+ (void)creditRequests:(NSString *)user page:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/credit-requests", user];
	NSDictionary *parameters = @{@"page": @(page)};
	[self GET:path parameters:parameters modelClass:[FTBCreditRequest class] success:success failure:failure];
}

+ (void)requestedCredits:(NSString *)user page:(NSUInteger)page success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = [NSString stringWithFormat:@"/users/%@/requested-credits", user];
	NSDictionary *parameters = @{@"page": @(page)};
	[self GET:path parameters:parameters modelClass:[FTBCreditRequest class] success:success failure:failure];
}

#pragma mark - Group

+ (void)createGroup:(NSString *)name pictureURL:(NSURL *)pictureURL success:(FTBBlockObject)success failure:(FTBBlockError)failure {
	NSString *path = @"/groups";
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	parameters[@"name"] = name;
	if (pictureURL) parameters[@"picture"] = pictureURL.absoluteString ?: @"";
	[self GET:path parameters:parameters modelClass:[FTBGroup class] success:success failure:failure];
}

@end
