//
//  LoginViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/7/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (assign, nonatomic) BOOL statusBarVisible;

@end

#pragma mark LoginViewController

@implementation LoginViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (IBAction)cancelAction:(id)sender {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.statusBarVisible = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] animations:^{
        self.backgroundImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

- (BOOL)prefersStatusBarHidden {
    return !self.statusBarVisible;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

#pragma mark - Delegates & Data sources

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    
    self.statusBarVisible = NO;
    
    UIImageView *originalBackgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    originalBackgroundImageView.image = [UIImage imageNamed:@"signup_bg"];
    originalBackgroundImageView.contentMode = UIViewContentModeTop;
    [self.view addSubview:originalBackgroundImageView];
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.backgroundImageView.image = [UIImage imageNamed:@"signup_step2_bg"];
    self.backgroundImageView.contentMode = UIViewContentModeTop;
    self.backgroundImageView.alpha = 0;
    [self.view addSubview:self.backgroundImageView];
    
    [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] animations:^{
        self.backgroundImageView.alpha = 1;
    } completion:^(BOOL finished) {
        self.statusBarVisible = YES;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self setNeedsStatusBarAppearanceUpdate];
    }];
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
