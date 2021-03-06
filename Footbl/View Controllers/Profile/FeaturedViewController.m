//
//  FeaturedViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/23/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <SPHipster/SPLog.h>

#import "FeaturedViewController.h"
#import "FTBClient.h"
#import "FTBUser.h"

@interface FeaturedViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSDate *lastUpdateAt;

@end

#pragma mark FeaturedViewController

@implementation FeaturedViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (void)reloadData {
    [super reloadData];
    
    self.lastUpdateAt = [NSDate date];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
    });
	
	[[FTBClient client] featuredUsers:0 success:^(id object) {
		[self.refreshControl endRefreshing];
	} failure:^(NSError *error) {
		[self.refreshControl endRefreshing];
		[[ErrorHandler sharedInstance] displayError:error];
	}];
}

#pragma mark - Delegates & Data sources

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Featured users title", @"");
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
