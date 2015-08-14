//
//  FTBClientTestCase.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FTBChampionship.h"
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
						   @"country": @"Brazil"};
	FTBChampionship *model = [FTBChampionship modelWithDictionary:dict];
	XCTAssertNotNil(model);
}

- (void)testSeasonCreation {
	NSDictionary *dict = @{@"_id": @"abc123",
						   @"createdAt": @"2015-08-11 23:26:00",
						   @"updatedAt": @"2015-08-11 23:26:00",
						   @"finishAt": @"2015-08-11 23:26:00",
						   @"sponsor": @"Apple Inc.",
						   @"gift": @"A $100 gift card."};
	FTBSeason *model = [FTBSeason modelWithDictionary:dict];
	XCTAssertNotNil(model);
}

@end
