//
//  NSString+Validations.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/7/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Validations)

- (BOOL)isEmail;
- (BOOL)isEmpty;
- (BOOL)isValidName;
- (BOOL)isValidPassword;
- (BOOL)isValidUsername;
- (BOOL)isValidAboutMe;

@end
