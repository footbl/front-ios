//
//  NewGroupViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/3/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "Championship.h"
#import "FriendsHelper.h"
#import "Group.h"
#import "GroupChampionshipsViewController.h"
#import "ImportImageHelper.h"
#import "NewGroupViewController.h"
#import "UIView+Shake.h"

@interface NewGroupViewController ()

@end

#pragma mark NewGroupViewController

@implementation NewGroupViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (IBAction)selectImageAction:(id)sender {
    [self.nameTextField resignFirstResponder];
    [[ImportImageHelper sharedInstance] importImageFromSources:@[@(ImportImageHelperSourceCamera), @(ImportImageHelperSourceLibrary)] completionBlock:^(UIImage *image, NSError *error) {
        if (image) {
            [self.groupImageButton setImage:image forState:UIControlStateNormal];
        }
        [self.nameTextField becomeFirstResponder];
    }];
}

- (IBAction)dismissAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)nextAction:(id)sender {
    if ([self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        [self shakeLimitLabel];
        return;
    }
    
    GroupChampionshipsViewController *championshipsViewController = [GroupChampionshipsViewController new];
    championshipsViewController.groupName = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    championshipsViewController.groupImage = [self.groupImageButton imageForState:UIControlStateNormal];
    [self.navigationController pushViewController:championshipsViewController animated:YES];
}

#pragma mark - Delegates & Data sources

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self nextAction:textField];
    
    return NO;
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"New Group", @"");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"") style:UIBarButtonItemStylePlain target:self action:@selector(nextAction:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.nameTextField becomeFirstResponder];
    
    [[FriendsHelper sharedInstance] reloadFriendsWithCompletionBlock:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
