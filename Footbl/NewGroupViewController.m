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
#import "GroupAddMembersViewController.h"
#import "ImportImageHelper.h"
#import "LoadingHelper.h"
#import "NewGroupViewController.h"
#import "UIView+Frame.h"
#import "UIView+Shake.h"

@interface NewGroupViewController ()

@end

#pragma mark NewGroupViewController

@implementation NewGroupViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (void)setInvitationMode:(BOOL)invitationMode {
    _invitationMode = invitationMode;
    
    if (self.nameTextField.text.length > 0) {
        self.nameTextField.text = @"";
    }
    
    if (self.isInvitationMode) {
        self.title = NSLocalizedString(@"Join Group", @"");
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(nextAction:)];
        self.nameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.nameSizeLimitLabel.text = NSLocalizedString(@"Insert invitation code", @"");
        [self.invitationModeButton setTitle:NSLocalizedString(@"Create a new group", @"") forState:UIControlStateNormal];
        
        [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.groupImageButton.frameY -= 100;
            self.groupImageButtonBorder.frameY = self.groupImageButton.frameY;
        } completion:nil];
    } else {
        self.title = NSLocalizedString(@"New Group", @"");
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"") style:UIBarButtonItemStylePlain target:self action:@selector(nextAction:)];
        self.nameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        self.nameSizeLimitLabel.text = NSLocalizedString(@"Insert group name", @"");
        [self.invitationModeButton setTitle:NSLocalizedString(@"Do you have an invitation code?", @"") forState:UIControlStateNormal];
        
        [UIView animateWithDuration:[FootblAppearance speedForAnimation:FootblAnimationDefault] * 2 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.groupImageButton.center = CGPointMake(self.groupImageButton.center.x, 120);
            self.groupImageButtonBorder.center = self.groupImageButton.center;
        } completion:nil];
    }
    
    [self.nameTextField resignFirstResponder];
    [self.nameTextField becomeFirstResponder];
}

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
    [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)nextAction:(id)sender {
    if (self.isInvitationMode) {
        if (self.nameTextField.text.length == 0) {
            [self shakeLimitLabel];
            return;
        }
        
        [self.nameTextField resignFirstResponder];
        [[LoadingHelper sharedInstance] showHud];
        
        [Group joinGroupWithCode:self.nameTextField.text success:^(id response) {
           [[LoadingHelper sharedInstance] hideHud];
            [self dismissAction:sender];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[LoadingHelper sharedInstance] hideHud];
            [[ErrorHandler sharedInstance] displayError:error];
        }];
        
        return;
    }
    
    if ([self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        [self shakeLimitLabel];
        return;
    }
    
    GroupAddMembersViewController *groupAddMembersViewController = [GroupAddMembersViewController new];
    groupAddMembersViewController.groupName = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    groupAddMembersViewController.groupImage = [self.groupImageButton imageForState:UIControlStateNormal];
    [self.navigationController pushViewController:groupAddMembersViewController animated:YES];
}

- (IBAction)invitationCodeAction:(id)sender {
    self.invitationMode = !self.isInvitationMode;
}

- (void)updateLimitTextForLength:(NSInteger)length {
    if (!self.isInvitationMode) {
        [super updateLimitTextForLength:length];
    }
}

#pragma mark - Delegates & Data sources

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self nextAction:textField];
    
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.isInvitationMode) {
        return YES;
    } else {
        return [super textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"New Group", @"");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"") style:UIBarButtonItemStylePlain target:self action:@selector(nextAction:)];
    
    self.invitationModeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 223, self.view.frameWidth, 40)];
    self.invitationModeButton.titleLabel.font = [UIFont fontWithName:kFontNameMedium size:14];
    [self.invitationModeButton setTitle:NSLocalizedString(@"Do you have an invitation code?", @"") forState:UIControlStateNormal];
    [self.invitationModeButton setTitleColor:[[FootblAppearance colorForView:FootblColorCellMatchPot] colorWithAlphaComponent:1.0] forState:UIControlStateNormal];
    [self.invitationModeButton setTitleColor:[[FootblAppearance colorForView:FootblColorCellMatchPot] colorWithAlphaComponent:0.4] forState:UIControlStateHighlighted];
    [self.invitationModeButton addTarget:self action:@selector(invitationCodeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.invitationModeButton];
    
    [self setInvitationMode:self.isInvitationMode];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.nameTextField becomeFirstResponder];
    
    [[FriendsHelper sharedInstance] getFriendsWithCompletionBlock:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
