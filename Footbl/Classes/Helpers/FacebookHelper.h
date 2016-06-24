//
//  FacebookHelper.h
//  Footbl
//
//  Created by Leonardo Formaggio on 6/23/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacebookHelper : NSObject

+ (void)performAuthenticatedAction:(void (^)(NSError *error))completion;

@end
