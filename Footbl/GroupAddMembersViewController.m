//
//  GroupAddMembersViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/3/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "Group.h"
#import "GroupAddMembersViewController.h"

@interface GroupAddMembersViewController ()

@end

#pragma mark GroupAddMembersViewController

@implementation GroupAddMembersViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (IBAction)createAction:(id)sender {
    [Group createWithChampionship:self.championship name:self.groupName success:nil failure:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Delegates & Data sources

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Add members", @"");
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Create", @"") style:UIBarButtonItemStylePlain target:self action:@selector(createAction:)];
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
