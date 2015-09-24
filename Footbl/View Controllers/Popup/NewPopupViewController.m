//
//  NewPopupViewController.m
//  Footbl
//
//  Created by Leonardo Formaggio on 9/23/15.
//  Copyright © 2015 Footbl. All rights reserved.
//

#import "NewPopupViewController.h"
#import "FootblPopupAnimatedTransition.h"
#import "UIView+Frame.h"

@interface NewPopupViewController () <UIViewControllerTransitioningDelegate>

@end

@implementation NewPopupViewController

#pragma mark - Instance Methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.modalPresentationStyle = UIModalPresentationCustom;
		self.transitioningDelegate = self;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor clearColor];
	
	CGFloat radius = 3;
	self.popupView.layer.cornerRadius = radius;
	self.popupView.clipsToBounds = YES;
	
	CGRect rect = CGRectMake(-0.5, -0.5, self.popupView.width + 1, self.popupView.height + 1);
	self.popupView.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius] CGPath];
	self.popupView.layer.shadowColor = [[UIColor blackColor] CGColor];
	self.popupView.layer.shadowOpacity = 0.39;
	self.popupView.layer.shadowOffset = CGSizeMake(0, 2);
	self.popupView.layer.shadowRadius = radius;
	self.popupView.clipsToBounds = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
	return [PopupTransitioningHide new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
																  presentingController:(UIViewController *)presenting
																	  sourceController:(UIViewController *)source {
	return [PopupTransitioningShow new];
}

@end
