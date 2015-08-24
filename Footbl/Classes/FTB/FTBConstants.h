//
//  FTBConstants.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/22/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *const FTBBaseURL;
NSString *const FTBSignatureKey;

typedef void (^FTBBlockObject)(id object);
typedef void (^FTBBlockError)(NSError *error);

#warning Remove the lines below

extern NSString * const kFTNotificationAPIOutdated;
extern NSString * const kFTNotificationAuthenticationChanged;
extern NSString * const kFTErrorDomain;
