//
//  TemplateViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <GoogleAnalytics/GAI.h>
#import <GoogleAnalytics/GAIFields.h>
#import <GoogleAnalytics/GAIDictionaryBuilder.h>
#import "TemplateViewController.h"

@interface TemplateViewController ()

@property (strong, nonatomic) NSDate *lastUpdateAt;
@property (strong, nonatomic) NSTimer *updateTimer;
@property (assign, nonatomic, getter = isVisible) BOOL visible;

@end

#pragma mark TemplateViewController

@implementation TemplateViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (void)reloadData {
    self.lastUpdateAt = [NSDate date];
}

- (NSTimeInterval)updateInterval {
    return UPDATE_INTERVAL;
}

- (void)checkForUpdate {
    if (self.isVisible && (!self.lastUpdateAt || [[NSDate date] timeIntervalSinceDate:self.lastUpdateAt] >= self.updateInterval - (self.updateInterval / 10))) {
        [self reloadData];
        [self.updateTimer invalidate];
        self.updateTimer = nil;
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:self.updateInterval target:self selector:@selector(checkForUpdate) userInfo:nil repeats:YES];
    }
}

#pragma mark - Delegates & Data sources

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
	
	self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor ftb_viewBackgroundColor];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:self.updateInterval target:self selector:@selector(checkForUpdate) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForUpdate) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.visible = YES;
    [self checkForUpdate];
    
    if (self.navigationController && self.navigationController.viewControllers.firstObject == self) {
        [[[GAI sharedInstance] defaultTracker] set:kGAIScreenName value:self.title];
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createScreenView] build]];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.visible = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.updateTimer invalidate];
    self.updateTimer = nil;
}

@end
