//
//  SPBlock.h
//  SPHipster
//
//  Created by Fernando Saragoça on 1/12/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <Foundation/Foundation.h>

extern void perform_block_after_delay(CGFloat seconds, dispatch_block_t block);
extern void perform_block_after_delay_k(CGFloat seconds, NSUInteger *key, dispatch_block_t block);
extern void cancel_block(NSUInteger key);

@interface SPBlock : NSObject

+ (void)performBlock:(dispatch_block_t)block afterDelay:(CGFloat)seconds withKey:(NSUInteger *)key;
+ (void)performBlock:(dispatch_block_t)block afterDelay:(CGFloat)seconds;
+ (void)cancelBlockWithKey:(NSUInteger)key;

@end