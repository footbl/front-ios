//
//  NSNumber+Formatter.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/21/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (Formatter)

- (NSString *)shortStringValue;
- (NSString *)rankingStringValue;
- (NSString *)potStringValue;
- (NSString *)walletStringValue;
- (NSString *)limitedWalletStringValue;

@end
