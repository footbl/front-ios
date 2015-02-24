//
//  SettingsTextViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/27/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "SettingsTextViewController.h"

@interface SettingsTextViewController ()

@property (strong, nonatomic) UITextView *textView;

@end

#pragma mark SettingsTextViewController

@implementation SettingsTextViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (void)setText:(NSString *)text {
    _text = text;
    
    self.textView.text = text;
}

#pragma mark - Instance Methods

#pragma mark - Delegates & Data sources

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.text = self.text;
    self.textView.editable = NO;
    self.textView.alwaysBounceVertical = YES;
    [self.view addSubview:self.textView];
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
