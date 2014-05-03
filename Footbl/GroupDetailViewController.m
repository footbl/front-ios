//
//  GroupDetailViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/2/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIButton+WebCache.h>
#import "Championship.h"
#import "Group.h"
#import "GroupDetailViewController.h"
#import "GroupInfoViewController.h"
#import "NSString+Hex.h"

@interface GroupDetailViewController ()

@end

#pragma mark GroupDetailViewController

@implementation GroupDetailViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (IBAction)groupInfoAction:(id)sender {
    GroupInfoViewController *groupInfoViewController = [GroupInfoViewController new];
    groupInfoViewController.group = self.group;
    [self.navigationController pushViewController:groupInfoViewController animated:YES];
}

- (void)reloadData {
    self.navigationItem.title = self.group.name;
    [self.rightNavigationBarButton setImageWithURL:[NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/6954324/Aplicativos/Footbl/Temp/Fifa%20World%20Cup%20Logo.png"] forState:UIControlStateNormal];
}

#pragma mark - Delegates & Data sources

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    
    self.title = NSLocalizedString(@"Group", @"");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.title style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.rightNavigationBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
    self.rightNavigationBarButton.layer.cornerRadius = CGRectGetWidth(self.rightNavigationBarButton.frame) / 2;
    self.rightNavigationBarButton.clipsToBounds = YES;
    [self.rightNavigationBarButton addTarget:self action:@selector(groupInfoAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightNavigationBarButton];
    
    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.group.isNewValue) {
        self.group.editableObject.isNew = @NO;
        SaveManagedObjectContext(self.group.editableManagedObjectContext);
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
