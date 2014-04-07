//
//  TutorialViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/7/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TutorialViewController.h"

@interface TutorialViewController ()

@end

#pragma mark TutorialViewController

@implementation TutorialViewController

NSString * kPresentTutorialViewController = @"kPresentTutorialViewController";

#pragma mark - Class Methods

+ (BOOL)shouldPresentTutorial {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kPresentTutorialViewController];
}

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (IBAction)closeAction:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:kPresentTutorialViewController];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.completionBlock) self.completionBlock();
}

#pragma mark - Delegates & Data sources

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Tutorial", @"");

    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.bounds), 40)];
    [closeButton setTitle:NSLocalizedString(@"Close tutorial", @"") forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:closeButton];
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
