//
//  FTBClientTestCase.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "FTBChampionship.h"
#import "FTBClient.h"
#import "FTBSeason.h"

@interface FTBClientTestCase : XCTestCase

@end

@implementation FTBClientTestCase

- (void)testChampionshipCreation {
	NSDictionary *dict = @{@"_id": @"abc123",
						   @"createdAt": @"2015-08-11 23:26:00",
						   @"updatedAt": @"2015-08-11 23:26:00",
						   @"name": @"Brasileiro",
						   @"type": @"national league",
						   @"picture": @"http://www.apple.com",
						   @"country": @"BR"};
	FTBChampionship *model = [FTBChampionship modelWithJSONDictionary:dict];
	XCTAssertNotNil(model);
    XCTAssertEqual(model.identifier, @"abc123");
    XCTAssertEqual(model.name, @"Brasileiro");
    XCTAssertEqual(model.type, FTBChampionshipTypeNationalLeague);
    XCTAssertEqualObjects(model.pictureURL, [NSURL URLWithString:@"http://www.apple.com"]);
    XCTAssertEqual(model.country, @"BR");
}

- (void)testSeasonCreation {
	NSDictionary *dict = @{@"_id": @"abc123",
						   @"createdAt": @"2015-08-11 23:26:00",
						   @"updatedAt": @"2015-08-11 23:26:00",
						   @"finishAt": @"2015-08-11 23:26:00",
						   @"sponsor": @"Apple Inc.",
						   @"gift": @"A $100 gift card."};
	FTBSeason *model = [FTBSeason modelWithJSONDictionary:dict];
	XCTAssertNotNil(model);
}

@end
