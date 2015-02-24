//
//  WhatsAppAPI.m
//  Footbl
//
//  Created by Fernando Saragoça on 6/24/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "WhatsAppAPI.h"

#pragma mark WhatsAppAPI

@implementation WhatsAppAPI

#pragma mark - Class Methods

+ (BOOL)isAvailable {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"whatsapp://send"]];
}

+ (BOOL)shareText:(NSString *)text {
    if (![self isAvailable]) {
        return NO;
    }
    
    CFStringRef encodedString = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)text, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    text = CFBridgingRelease(encodedString);
    
    NSString *urlString = [NSString stringWithFormat:@"whatsapp://send?text=%@", text];
    NSURL *whatsAppURL = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:whatsAppURL];
        
    return YES;
}

@end
