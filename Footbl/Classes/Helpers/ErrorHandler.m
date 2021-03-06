//
//  ErrorHandler.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/27/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "ErrorHandler.h"

@interface ErrorHandler () <UIAlertViewDelegate>

@end

#pragma mark ErrorHandler

@implementation ErrorHandler

#pragma mark - Class Methods

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (ErrorBlock)failureBlock {
    return [[self sharedInstance] failureBlock];
}

#pragma mark - Instance Methods

- (id)init {
    self = [super init];
    if (self) {
        self.shouldShowError = YES;
    }
    return self;
}

- (void)displayError:(NSError *)error {
    if (self.isAlertVisible) {
        return;
    }
    
    if (!self.shouldShowError) {
        return;
    }
    
    if (!error || error.localizedDescription.length == 0) {
        return;
    }
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
    
    _alertVisible = YES;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:error.localizedDescription delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
    [alert show];
}

- (ErrorBlock)failureBlock {
    ErrorBlock errorBlock = ^(NSError *error){
        [self displayError:error];
    };
    return errorBlock;
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    _alertVisible = NO;
}

@end
