//
//  NSString+Validations.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/7/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "NSString+Validations.h"

#pragma mark NSString (Validations)

@implementation NSString (Validations)

#pragma mark - Instance Methods

- (BOOL)isEmail {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\A[^@]+@[^@]+\\z" options:0 error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)];
    return numberOfMatches > 0;
}

- (BOOL)isValidName {
    return self.length > 4;
}

- (BOOL)isEmpty {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0;
}

- (BOOL)isValidPassword {
    return self.length >= 6;
}

- (BOOL)isValidUsername {
    return self.length > 4;
}

- (BOOL)isValidAboutMe {
    return self.length <= 66;
}

@end
