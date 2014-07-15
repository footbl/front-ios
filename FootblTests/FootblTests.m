//
//  FootblTests.m
//  FootblTests
//
//  Created by Fernando Saragoça on 3/25/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <KIF/KIF.h>
#import <XCTest/XCTest.h>
#import "FootblAPI.h"

@interface FootblTests : KIFTestCase

@end

#pragma mark FootblTests

@implementation FootblTests

#pragma mark - Instance Methods

- (void)beforeAll {
    [[FootblAPI sharedAPI] logout];
}

- (void)afterAll {
    [[FootblAPI sharedAPI] logout];
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSignup {
    NSString *email = @"test@footbl.co";
    NSString *name = @"Alfredo";
    NSString *invalidPassword = @"senha";
    NSString *validPassword = @"password";
    NSString *username = @"alfredo_tester";
    NSString *bio = @"I'm Alfredo, official footbl tester.";
    
    // Create account button
    [tester waitForTimeInterval:1];
    [tester tapViewWithAccessibilityLabel:NSLocalizedString(@"Create my account", @"")];
    
    // Enter email
    [tester waitForKeyboard];
    [tester enterTextIntoCurrentFirstResponder:email];
    [tester waitForTimeInterval:1];
    [tester tapViewWithAccessibilityLabel:NSLocalizedString(@"Continue", @"")];
    
    // Ensure email is correct
    [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:NSLocalizedString(@"You entered your email as %@", @""), email]];
    [tester tapViewWithAccessibilityLabel:NSLocalizedString(@"Yes", @"")];
    [tester waitForTimeInterval:1];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:NSLocalizedString(@"Loading", @"Loading")];
    
    // Enter name
    [tester enterTextIntoCurrentFirstResponder:name];
    [tester waitForTimeInterval:1];
    [tester tapViewWithAccessibilityLabel:NSLocalizedString(@"Continue", @"")];
    
    // Enter invalid password
    [tester enterTextIntoCurrentFirstResponder:invalidPassword];
    [tester waitForTimeInterval:1];
    [tester tapViewWithAccessibilityLabel:NSLocalizedString(@"Continue", @"")];
    [tester waitForViewWithAccessibilityLabel:NSLocalizedString(@"Sign up text: password hint", @"")];
    [tester waitForTimeInterval:1];
    [tester clearTextFromAndThenEnterText:@"" intoViewWithAccessibilityLabel:@""];
    [tester waitForTimeInterval:1];
    
    // Enter valid password
    [tester enterTextIntoCurrentFirstResponder:validPassword];
    [tester waitForTimeInterval:1];
    [tester tapViewWithAccessibilityLabel:NSLocalizedString(@"Continue", @"")];
    
    // Enter username
    [tester enterTextIntoCurrentFirstResponder:username];
    [tester waitForTimeInterval:1];
    [tester tapViewWithAccessibilityLabel:NSLocalizedString(@"Continue", @"")];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:NSLocalizedString(@"Loading", @"Loading")];
    
    // Enter bio
    [tester enterTextIntoCurrentFirstResponder:bio];
    [tester waitForTimeInterval:1];
    [tester tapViewWithAccessibilityLabel:NSLocalizedString(@"Continue", @"")];
    
    // Cancel
    [tester waitForTimeInterval:1];
    [tester tapScreenAtPoint:CGPointMake(20, 40)];
    [tester waitForTimeInterval:1];
}

@end
