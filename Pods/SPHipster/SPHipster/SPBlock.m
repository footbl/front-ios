//
//  SPBlock.m
//  SPHipster
//
//  Created by Fernando Saragoça on 1/12/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "SPBlock.h"

#pragma mark SPBlock - Hipster Mode

#pragma mark - Extern Functions

static NSMutableDictionary *blocksDictionary() {
    static NSMutableDictionary *dictionary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictionary = [NSMutableDictionary new];
    });
    return dictionary;
}

void perform_block_after_delay_k(CGFloat seconds, NSUInteger *key, dispatch_block_t block) {
    @synchronized(blocksDictionary()) {
        if (block == nil) {
            return;
        }
        
        __block dispatch_block_t performableBlock = [block copy];
        
        NSNumber *hash = @([performableBlock hash]);
        if (key) {
            *key = hash.unsignedIntegerValue;
        }
        
        blocksDictionary()[hash] = @YES;
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (blocksDictionary()[hash]) {
                dispatch_async(dispatch_get_main_queue(), performableBlock);
                [blocksDictionary() removeObjectForKey:hash];
            }
        });
    }
}

void perform_block_after_delay(CGFloat seconds, dispatch_block_t block) {
    perform_block_after_delay_k(seconds, nil, block);
}

void cancel_block(NSUInteger key) {
    @synchronized(blocksDictionary()) {
        [blocksDictionary() removeObjectForKey:@(key)];
    }
}

#pragma mark - SPBlock - Classic Mode

@implementation SPBlock

#pragma mark - Class Methods

+ (void)performBlock:(dispatch_block_t)block afterDelay:(CGFloat)seconds withKey:(NSUInteger *)key {
    perform_block_after_delay_k(seconds, key, block);
}

+ (void)performBlock:(dispatch_block_t)block afterDelay:(CGFloat)seconds {
    [self performBlock:block afterDelay:seconds withKey:nil];
}

+ (void)cancelBlockWithKey:(NSUInteger)key {
    cancel_block(key);
}

@end