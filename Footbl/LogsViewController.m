//
//  LogsViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/25/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SPHipster/SPHipster.h>
#import "LogsViewController.h"

@interface LogsViewController ()

@end

#pragma mark LogsViewController

@implementation LogsViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (IBAction)shareAction:(id)sender {
    NSString *text = [[NSString alloc] initWithContentsOfFile:SPLogFilePath() encoding:NSUTF8StringEncoding error:nil];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[text] applicationActivities:@[]];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypePostToFacebook, UIActivityTypePostToFlickr, UIActivityTypePostToTencentWeibo, UIActivityTypePostToTwitter, UIActivityTypePostToVimeo, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark - Delegates & Data sources

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Logs", @"");
    
    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.text = [[NSString alloc] initWithContentsOfFile:SPLogFilePath() encoding:NSUTF8StringEncoding error:nil];
    [self.view addSubview:self.textView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction:)];
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