//
//  WhatsAppAPI.h
//  Footbl
//
//  Created by Fernando Saragoça on 6/24/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WhatsAppAPI : NSObject

+ (BOOL)isAvailable;
+ (BOOL)shareText:(NSString *)text;

@end
