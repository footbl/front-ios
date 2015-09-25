//
//  UINavigationBar+UIProgressView.m
//  Footbl
//
//  Created by Leonardo Formaggio on 9/24/15.
//  Copyright © 2015 Footbl. All rights reserved.
//

#import "UINavigationBar+UIProgressView.h"

@implementation UINavigationBar (UIProgressView)

- (void)addProgressView:(UIProgressView *)progressView {
	progressView.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:progressView];
	
	NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[progressView]|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(progressView)];
	[self addConstraints:horizontalConstraints];
	
	NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[self][progressView]" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(self, progressView)];
	[self addConstraints:verticalConstraints];
}

@end
