//
//  TutorialViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/7/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <StyledPageControl/StyledPageControl.h>
#import "TutorialViewController.h"
#import "UIView+Frame.h"

@interface TutorialViewController ()

@property (assign, nonatomic) BOOL shouldUpdatePageControl;

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

- (IBAction)nextAction:(id)sender {
    self.nextButton.userInteractionEnabled = NO;
    
    self.shouldUpdatePageControl = NO;
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + self.scrollView.width, self.scrollView.contentOffset.y) animated:YES];
    if (self.pageControl.currentPage == 3) {
        [self scrollViewDidScroll:self.scrollView];
    } else {
        self.pageControl.currentPage = self.pageControl.currentPage + 1;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.shouldUpdatePageControl = YES;
        self.nextButton.userInteractionEnabled = YES;
    });
}

#pragma mark - Delegates & Data sources

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = (NSInteger)(scrollView.contentOffset.x / scrollView.width);
    if (page < 4 && self.shouldUpdatePageControl) {
        self.pageControl.currentPage = (int)page;
    }
    
    [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] animations:^{
        self.pageControl.alpha = (page != 4);
        self.nextButton.alpha = self.pageControl.alpha;
        self.getStartedButton.alpha = !self.pageControl.alpha;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] animations:^{
            self.getStartedButton.alpha = !self.pageControl.alpha;
        }];
    }];
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.navigationController.navigationBarHidden = YES;
    self.shouldUpdatePageControl = YES;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 60)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = NO;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.clipsToBounds = NO;
    [self.view addSubview:self.scrollView];
    
    for (NSInteger i = 0; i < 5; i++) {
        NSString *imageName = [NSString stringWithFormat:@"tutorial_%@", @(i + 1).stringValue];
        if ([UIScreen mainScreen].bounds.size.height <= 480) {
            imageName = [imageName stringByAppendingString:@"_480"];
        }
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        imageView.frame = self.view.bounds;
        imageView.x = i * self.view.width;
        imageView.y -= 20;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.scrollView addSubview:imageView];
        self.scrollView.contentSize = CGSizeMake(imageView.x + self.scrollView.width, 0);
    }
    
    self.pageControl = [[StyledPageControl alloc] initWithFrame:CGRectMake(0, self.view.height - 60, self.view.width, 60)];
    self.pageControl.numberOfPages = 5;
    self.pageControl.currentPage = 0;
    self.pageControl.diameter = 11;
    self.pageControl.gapWidth = 9;
    self.pageControl.coreNormalColor = [UIColor colorWithRed:0.32 green:0.81 blue:0.52 alpha:1];
    self.pageControl.coreSelectedColor = [UIColor whiteColor];
    self.pageControl.userInteractionEnabled = NO;
    [self.view addSubview:self.pageControl];
    
    self.nextButton = [[UIButton alloc] initWithFrame:CGRectMake(200, self.pageControl.y, self.view.width - 200, self.pageControl.height)];
    self.nextButton.titleLabel.font = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:17];
    [self.nextButton setTitle:NSLocalizedString(@"Next", @"") forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.nextButton setTitleColor:self.pageControl.coreNormalColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.nextButton];
    
    self.getStartedButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.pageControl.y, self.view.width, self.pageControl.height)];
    self.getStartedButton.alpha = 0;
    self.getStartedButton.titleLabel.font = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:17];
    [self.getStartedButton setTitle:NSLocalizedString(@"Get started", @"") forState:UIControlStateNormal];
    [self.getStartedButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.getStartedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.getStartedButton setTitleColor:self.pageControl.coreNormalColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.getStartedButton];
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
