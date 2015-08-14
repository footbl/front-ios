//
//  WhatsAppActivity.m
//  Chegou
//
//  Created by Fernando Saragoça on 12/16/13.
//  Copyright (c) 2013 Footbl. All rights reserved.
//

#import "WhatsAppActivity.h"
#import "WhatsAppAPI.h"

@interface WhatsAppActivity ()

@property (strong, nonatomic) NSArray *activityItems;

@end

#pragma mark WhatsAppActivity

@implementation WhatsAppActivity

#pragma mark - Instance Methods

- (NSString *)activityType {
	return NSStringFromClass([self class]);
}

- (NSString *)activityTitle {
	return NSLocalizedString(@"WhatsApp", @"WhatsApp");
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"whatsapp_icon_iphone"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return [WhatsAppAPI isAvailable];
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    [super prepareWithActivityItems:activityItems];
    self.activityItems = activityItems;
}

- (void)performActivity {
    NSString *text;
    for (id object in self.activityItems) {
        if ([object isKindOfClass:[NSString class]]) {
            text = [object stringByAppendingString:@" "];
            break;
        }
    }
    [WhatsAppAPI shareText:text];
    
    [self activityDidFinish:YES];
}

@end
