//
//  GroupDetailViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/2/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIButton+WebCache.h>
#import <SPHipster/UIView+Frame.h>
#import "FootblNavigationController.h"
#import "FootblTabBarController.h"
#import "Group.h"
#import "GroupChatViewController.h"
#import "GroupDetailViewController.h"
#import "GroupInfoViewController.h"
#import "GroupRankingViewController.h"
#import "GroupAroundMeViewController.h"

@interface GroupDetailViewController ()

typedef NS_ENUM(NSUInteger, GroupDetailType) {
    GroupDetailTypeNone = 0,
    GroupDetailTypeChat = 1,
    GroupDetailTypeAroundMe = 2,
};

@property (strong, nonatomic) GroupRankingViewController *groupRankingViewController;
@property (strong, nonatomic) GroupChatViewController *groupChatViewController;
@property (strong, nonatomic) GroupAroundMeViewController *groupAroundMeViewController;
@property (strong, nonatomic) UIView *segmentedControlBackgroundView;
@property (strong, nonatomic) UIView *separatorView;
@property (nonatomic) GroupDetailType groupType;
@property (nonatomic) GroupDetailContext context;

@end

#define GROUP_CHAT_ENABLED FBTweakValue(@"UX", @"Group", @"Chat", NO)
#define AROUND_ME_ENABLED FBTweakValue(@"UX", @"Group", @"Around me ranking", NO)

#pragma mark GroupDetailViewController

@implementation GroupDetailViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (GroupChatViewController *)groupChatViewController {
    if (!_groupChatViewController && self.groupType == GroupDetailTypeChat) {
        _groupChatViewController = [GroupChatViewController new];
        _groupChatViewController.group = self.group;
        [self addChildViewController:_groupChatViewController];
        [self.view addSubview:_groupChatViewController.view];
        [self.view sendSubviewToBack:_groupChatViewController.view];
        _groupChatViewController.view.frame = CGRectMake(0, self.segmentedControlBackgroundView.frameHeight, self.view.frameWidth, self.view.frameHeight - self.segmentedControlBackgroundView.frameHeight);
    }
    
    return _groupChatViewController;
}

- (GroupRankingViewController *)groupRankingViewController {
    if (!_groupRankingViewController) {
        _groupRankingViewController = [GroupRankingViewController new];
        _groupRankingViewController.group = self.group;
        _groupRankingViewController.context = self.context;
        [self addChildViewController:_groupRankingViewController];
        [self.view addSubview:_groupRankingViewController.view];
        [self.view sendSubviewToBack:_groupRankingViewController.view];
        if (self.segmentedControl) {
            _groupRankingViewController.view.frame = CGRectMake(0, self.segmentedControlBackgroundView.frameHeight, self.view.frameWidth, self.view.frameHeight - self.segmentedControlBackgroundView.frameHeight);
        } else {
            _groupRankingViewController.view.frame = self.view.bounds;
        }
    }
    
    return _groupRankingViewController;
}

- (GroupAroundMeViewController *)groupAroundMeViewController {
    if (!_groupAroundMeViewController) {
        _groupAroundMeViewController = [GroupAroundMeViewController new];
        _groupAroundMeViewController.group = self.group;
        _groupAroundMeViewController.context = self.context;
        [self addChildViewController:_groupAroundMeViewController];
        [self.view addSubview:_groupAroundMeViewController.view];
        [self.view sendSubviewToBack:_groupAroundMeViewController.view];
        _groupAroundMeViewController.view.frame = CGRectMake(0, self.segmentedControlBackgroundView.frameHeight, self.view.frameWidth, self.view.frameHeight - self.segmentedControlBackgroundView.frameHeight);
    
    }
    
    return _groupAroundMeViewController;
}

- (GroupDetailType)groupType {
    if (!self.group.isDefaultValue && GROUP_CHAT_ENABLED) {
        _groupType = GroupDetailTypeChat;
    } else if (self.group.isDefaultValue && AROUND_ME_ENABLED) {
        _groupType = GroupDetailTypeAroundMe;
    } else {
        _groupType = GroupDetailTypeNone;
    }
    
    return _groupType;
}

- (GroupDetailContext)context {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0: {
            if (self.groupType == GroupDetailTypeChat) {
                _context = GroupDetailContextChat;
            } else {
                _context = GroupDetailContextRanking;
            }
           break;
        }
        case 1: {
            if (self.groupType == GroupDetailTypeAroundMe) {
                _context = GroupDetailContextAroundMe;
            } else {
                _context = GroupDetailContextRanking;
            }
            break;
        }
        default: {
            _context = GroupDetailContextRanking;
            break;
        }
    }
    
    return _context;
}

#pragma mark - Instance Methods

- (IBAction)groupInfoAction:(id)sender {
    GroupInfoViewController *groupInfoViewController = [GroupInfoViewController new];
    groupInfoViewController.group = self.group;
    [self.navigationController pushViewController:groupInfoViewController animated:YES];
}

- (IBAction)segmentedControlAction:(id)sender {
    [self reloadData];
}

- (NSTimeInterval)updateInterval {
    return UPDATE_INTERVAL_NEVER;
}

- (void)reloadData {
    [super reloadData];
    
    self.navigationItem.title = self.group.name;
    [self.rightNavigationBarButton sd_setImageWithURL:[NSURL URLWithString:self.group.picture] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"generic_group"]];
    
    if (self.context == GroupDetailContextChat) {
        self.groupAroundMeViewController.view.hidden = YES;
        self.groupChatViewController.view.hidden = NO;
        self.groupRankingViewController.view.hidden = YES;
    } else if (self.context == GroupDetailContextAroundMe) {
        self.groupAroundMeViewController.view.hidden = NO;
        self.groupChatViewController.view.hidden = YES;
        self.groupRankingViewController.view.hidden = YES;
    } else {
        self.groupAroundMeViewController.view.hidden = YES;
        self.groupChatViewController.view.hidden = YES;
        self.groupRankingViewController.view.hidden = NO;
    }
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
    
    if (self.groupType != GroupDetailTypeNone) {
        NSArray *segmentItems;
        if (self.groupType == GroupDetailTypeChat) {
            segmentItems = @[NSLocalizedString(@"Chat", @""), NSLocalizedString(@"Ranking", @"")];
        } else if (self.groupType == GroupDetailTypeAroundMe) {
            segmentItems = @[NSLocalizedString(@"Top", @""), NSLocalizedString(@"Around Me", @"")];
        }
        self.segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentItems];
        self.segmentedControl.frame = CGRectMake(15, 73, CGRectGetWidth(self.view.frame) - 30, 29);
        self.segmentedControl.tintColor = [FootblAppearance colorForView:FootblColorTabBarTint];
        self.segmentedControl.selectedSegmentIndex = 0;
        self.segmentedControl.backgroundColor = self.view.backgroundColor;
        [self.segmentedControl addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:self.segmentedControl];
        
        self.segmentedControlBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 47)];
        self.segmentedControlBackgroundView.backgroundColor = self.segmentedControl.backgroundColor;
        [self.view insertSubview:self.segmentedControlBackgroundView belowSubview:self.segmentedControl];
        
        self.separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 111, CGRectGetWidth(self.view.frame), 0.5)];
        self.separatorView.backgroundColor = [FootblAppearance colorForView:FootblColorCellSeparator];
        [self.view insertSubview:self.separatorView belowSubview:self.segmentedControlBackgroundView];
    }
    
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
    
    if (self.context == GroupDetailContextChat) {
        [self.groupChatViewController reloadData];
    } else if (self.context == GroupDetailContextAroundMe){
        [self.groupAroundMeViewController reloadData];
    } else {
        [self.groupRankingViewController reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = self.group.name;
    [self.rightNavigationBarButton sd_setImageWithURL:[NSURL URLWithString:self.group.picture] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"generic_group"]];
    
    [self.groupRankingViewController viewWillAppear:animated];
    [self.groupChatViewController viewWillAppear:animated];
    [self.groupAroundMeViewController viewWillAppear:animated];
    
    [(FootblTabBarController *)self.tabBarController setTabBarHidden:YES animated:YES];
    
    [self reloadData];
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
    
    [(FootblTabBarController *)self.tabBarController setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.navigationController.viewControllers.count <= 2) {
        [(FootblTabBarController *)self.tabBarController setTabBarHidden:NO animated:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (!self.navigationController) {
        [self.groupChatViewController.view removeFromSuperview];
        [self.groupRankingViewController.view removeFromSuperview];
        [self.groupAroundMeViewController.view removeFromSuperview];
        [self.groupRankingViewController removeFromParentViewController];
        [self.groupChatViewController removeFromParentViewController];
        [self.groupAroundMeViewController removeFromParentViewController];
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
