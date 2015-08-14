//
//  FootblPopupViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/30/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "FootblPopupAnimatedTransition.h"
#import "FootblPopupViewController.h"

@interface FootblPopupViewController () <UIViewControllerTransitioningDelegate>

@end

#pragma mark FootblPopupViewController

@implementation FootblPopupViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
        [self addChildViewController:rootViewController];
    }
    return self;
}

- (void)dismissViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Delegates & Data sources

#pragma mark - UIViewController transition delegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    FootblPopupAnimatedTransition *animatedTransition = [FootblPopupAnimatedTransition new];
    animatedTransition.presenting = NO;
    return animatedTransition;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    FootblPopupAnimatedTransition *animatedTransition = [FootblPopupAnimatedTransition new];
    animatedTransition.presenting = YES;
    return animatedTransition;
}

#pragma mark - View Lifecycle

- (BOOL)prefersStatusBarHidden {
    return FBTweakValue(@"UI", @"Popup", @"Hide status bar", NO);
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    for (UIViewController *viewController in self.childViewControllers) {
        [self.view addSubview:viewController.view];
        viewController.view.frame = self.view.bounds;
        viewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        viewController.view.clipsToBounds = YES;
        viewController.view.layer.cornerRadius = 3;
    }
    
    if (self.childViewControllers.count == 0) {
        self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 101)];
        self.headerImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.headerImageView.backgroundColor = [UIColor colorWithRed:52./255.f green:206/255.f blue:122/255.f alpha:1.0];
        self.headerImageView.contentMode = UIViewContentModeCenter;
        [self.view addSubview:self.headerImageView];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
