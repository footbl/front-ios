//
//  GroupDetailViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/2/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIButton+WebCache.h>
#import "FootblNavigationController.h"
#import "Group.h"
#import "GroupDetailViewController.h"
#import "GroupInfoViewController.h"
#import "GroupRankingViewController.h"

@interface GroupDetailViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSNumber *nextPage;
@property (strong, nonatomic) GroupRankingViewController *groupRankingViewController;

@end

#pragma mark GroupDetailViewController

@implementation GroupDetailViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (GroupRankingViewController *)groupRankingViewController {
    if (!_groupRankingViewController) {
        _groupRankingViewController = [GroupRankingViewController new];
        _groupRankingViewController.group = self.group;
        [self addChildViewController:_groupRankingViewController];
        [self.view addSubview:_groupRankingViewController.view];
        _groupRankingViewController.view.frame = self.view.bounds;
    }
    
    return _groupRankingViewController;
}

#pragma mark - Instance Methods

- (IBAction)groupInfoAction:(id)sender {
    GroupInfoViewController *groupInfoViewController = [GroupInfoViewController new];
    groupInfoViewController.group = self.group;
    [self.navigationController pushViewController:groupInfoViewController animated:YES];
}

- (NSTimeInterval)updateInterval {
    return UPDATE_INTERVAL_NEVER;
}

- (void)reloadData {
    [super reloadData];
    
    self.navigationItem.title = self.group.name;
    [self.rightNavigationBarButton sd_setImageWithURL:[NSURL URLWithString:self.group.picture] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"generic_group"]];
}

- (void)setupTitleView {
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSMutableDictionary *titleAttributes = [[[UINavigationBar appearanceWhenContainedIn:[FootblNavigationController class], nil] titleTextAttributes] mutableCopy];
    titleAttributes[NSParagraphStyleAttributeName] = paragraphStyle;
    NSMutableDictionary *highlightedAttributes = [titleAttributes mutableCopy];
    highlightedAttributes[NSForegroundColorAttributeName] = [highlightedAttributes[NSForegroundColorAttributeName] colorWithAlphaComponent:0.2];
    NSMutableDictionary *subAttributes = [titleAttributes mutableCopy];
    subAttributes[NSForegroundColorAttributeName] = [UIColor lightGrayColor];
    subAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:11];
    NSMutableDictionary *highlightedSubAttributes = [subAttributes mutableCopy];
    highlightedSubAttributes[NSForegroundColorAttributeName] = [highlightedSubAttributes[NSForegroundColorAttributeName] colorWithAlphaComponent:0.2];
    
    UIButton *titleViewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleViewButton.titleLabel.numberOfLines = 2;
    
    NSAttributedString *buttonText = [[NSAttributedString alloc] initWithString:self.title attributes:titleAttributes];

    NSAttributedString *highlightedButtonText = [[NSAttributedString alloc] initWithString:self.title attributes:highlightedAttributes];
    
    [titleViewButton setAttributedTitle:buttonText forState:UIControlStateNormal];
    [titleViewButton setAttributedTitle:highlightedButtonText forState:UIControlStateHighlighted];
    [titleViewButton addTarget:self action:@selector(groupInfoAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleViewButton;
}

#pragma mark - Delegates & Data sources

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    
    self.title = self.group.name;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.title style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self setupTitleView];
    
    self.rightNavigationBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 38, 38)];
    self.rightNavigationBarButton.layer.cornerRadius = CGRectGetWidth(self.rightNavigationBarButton.frame) / 2;
    self.rightNavigationBarButton.clipsToBounds = YES;
    [self.rightNavigationBarButton addTarget:self action:@selector(groupInfoAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightNavigationBarButton];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        self.navigationItem.title = self.group.name;
        [self.rightNavigationBarButton sd_setImageWithURL:[NSURL URLWithString:self.group.picture] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"generic_group"]];
    }];
    
    [self reloadData];
    [[self groupRankingViewController] reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = self.group.name;
    [self.rightNavigationBarButton sd_setImageWithURL:[NSURL URLWithString:self.group.picture] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"generic_group"]];
    
    [[self groupRankingViewController] viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.group.isNewValue) {
        [[FTCoreDataStore privateQueueContext] performBlock:^{
            self.group.editableObject.isNew = @NO;
            [self.group saveStatusInLocalDatabase];
            [[FTCoreDataStore privateQueueContext] performSave];
        }];
    }
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
