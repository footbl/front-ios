//
//  GroupInfoViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/2/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import <SDWebImage/UIButton+WebCache.h>
#import "FootblNavigationController.h"
#import "GroupInfoViewController.h"
#import "ImportImageHelper.h"
#import "UIView+Frame.h"
#import "UIView+Shake.h"
#import "WhatsAppActivity.h"
#import "WhatsAppAPI.h"
#import "FTImageUploader.h"

#import "FTBClient.h"
#import "FTBChampionship.h"
#import "FTBGroup.h"
#import "FTBUser.h"

@interface GroupInfoViewController () <UIScrollViewDelegate>

@end

#pragma mark GroupInfoViewController

@implementation GroupInfoViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (IBAction)selectImageAction:(id)sender {
    BOOL keyboardIsFirstResponder = self.nameTextField.isFirstResponder;
    [self.nameTextField resignFirstResponder];
    [[ImportImageHelper sharedInstance] importImageFromSources:@[@(ImportImageHelperSourceCamera), @(ImportImageHelperSourceLibrary)] completionBlock:^(UIImage *image, NSError *error) {
        if (image) {
            [self.groupImageButton setImage:image forState:UIControlStateNormal];
            [FTImageUploader uploadImage:image withCompletion:^(NSString *imagePath, NSError *error) {
				self.group.pictureURL = [NSURL URLWithString:imagePath];
				[[FTBClient client] updateGroup:self.group success:nil failure:nil];
			}];
        }
        if (keyboardIsFirstResponder) {
            [self.nameTextField becomeFirstResponder];
        }
    }];
}

- (IBAction)leaveGroupAction:(id)sender {
	[[FTBClient client] removeGroup:self.group success:nil failure:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)notificationsSwitchValueChangedAction:(UISwitch *)switchView {
    switchView.userInteractionEnabled = NO;
#warning Implement group notifications API
//    [self.group.myMembership setNotificationsEnabled:switchView.isOn success:^(id response) {
//        switchView.userInteractionEnabled = YES;
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        switchView.userInteractionEnabled = YES;
//        [switchView setOn:!switchView.isOn animated:YES];
//        [[ErrorHandler sharedInstance] displayError:error];
//    }];
}

- (IBAction)copySharingCodeAction:(id)sender {
    if ([WhatsAppAPI isAvailable]) {
        [WhatsAppAPI shareText:self.group.sharingText];
    } else {
        [[UIPasteboard generalPasteboard] setString:self.group.sharingText];
        
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        hud.mode = MBProgressHUDModeText;
        hud.animationType = MBProgressHUDAnimationZoom;
        hud.labelText = NSLocalizedString(@"Copied!", @"");
        [self.view addSubview:hud];
        [hud show:YES];
        [hud hide:YES afterDelay:1];
    }
}

- (IBAction)shareAction:(id)sender {
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.group.sharingText] applicationActivities:@[[WhatsAppActivity new]]];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypePostToFlickr, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)updateGroupName {
    if (![self.nameTextField.text isEqualToString:self.group.name] && [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        self.group.name = self.nameTextField.text;
		[[FTBClient client] updateGroup:self.group success:nil failure:nil];
    }
}

- (void)tapGroupCodeGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    [[UIPasteboard generalPasteboard] setString:self.group.identifier];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.mode = MBProgressHUDModeText;
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.labelText = NSLocalizedString(@"Copied!", @"");
    [self.view addSubview:hud];
    [hud show:YES];
    [hud hide:YES afterDelay:1];
}

- (void)dismissKeyboardGesture:(UITapGestureRecognizer *)gestureRecognizer {
    [self textFieldShouldReturn:self.nameTextField];
}

- (void)reloadData {
    [super reloadData];
	
    self.nameTextField.text = self.group.name;
    self.nameTextField.userInteractionEnabled = NO;
    [self.groupImageButton sd_setImageWithURL:self.group.pictureURL forState:UIControlStateNormal];
}

#pragma mark - Delegates & Data sources

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self updateLimitTextForLength:MAX_GROUP_NAME_SIZE - self.nameTextField.text.length];
    self.nameSizeLimitLabel.userInteractionEnabled = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (!self.group.isDefault) {
        self.nameSizeLimitLabel.userInteractionEnabled = YES;
        self.nameSizeLimitLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Group code: %@", @"Group code: {group code}"), self.group.identifier];
        [self.nameTextField resignFirstResponder];
    } else {
        [super textFieldDidEndEditing:textField];
    }

    [self updateGroupName];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        [textField resignFirstResponder];
        return YES;
    } else {
        [self shakeLimitLabel];
        return NO;
    }
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
 
    self.title = NSLocalizedString(@"Group Info", @"");

    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardGesture:)]];
    
    if (!self.group.isDefault) {
        self.nameTextField.y -= 2;
        self.nameSizeLimitLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Group code: %@", @"Group code: {group code}"), self.group.identifier];
        self.nameSizeLimitLabel.alpha = 1;
        self.nameSizeLimitLabel.userInteractionEnabled = YES;
        [self.nameSizeLimitLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGroupCodeGestureRecognizer:)]];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction:)];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    for (UIView *view in self.view.subviews) {
        if (view == scrollView) {
            continue;
        }
        [scrollView addSubview:view];
        view.y -= 64;
    }
    
    UIView * (^generateView)(CGRect frame) = ^(CGRect frame) {
        frame.origin.x -= 1;
        frame.size.width += 2;
        UIView *view = [[UIView alloc] initWithFrame:frame];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.borderColor = [UIColor colorWithRed:227/255.f green:232/255.f blue:228/255.f alpha:1.00].CGColor;
        view.layer.borderWidth = 0.5;
        [scrollView addSubview:view];
        return view;
    };
    
    CGRect bottomRect = CGRectMake(0, 9, CGRectGetWidth(self.view.frame), 159);
    
    if (self.group.isDefault) {
        UIView *copyShareCodeView = generateView(CGRectMake(0, CGRectGetMaxY(bottomRect) - 0.5, CGRectGetWidth(self.view.frame), 72));
        UIButton *copyShareCodeButton = [[UIButton alloc] initWithFrame:copyShareCodeView.frame];
        [copyShareCodeButton setTitle:NSLocalizedString(@"Copy sharing code", @"") forState:UIControlStateNormal];
        [copyShareCodeButton setTitleColor:[[UIColor ftb_cellMatchPotColor] colorWithAlphaComponent:1.0] forState:UIControlStateNormal];
        [copyShareCodeButton setTitleColor:[[UIColor ftb_cellMatchPotColor] colorWithAlphaComponent:0.2] forState:UIControlStateHighlighted];
        copyShareCodeButton.titleLabel.font = [UIFont fontWithName:kFontNameMedium size:16];
        copyShareCodeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        copyShareCodeButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 17, 0);
        [copyShareCodeButton addTarget:self action:@selector(copySharingCodeAction:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:copyShareCodeButton];
        
        UILabel *sharingLabel = [[UILabel alloc] initWithFrame:copyShareCodeButton.frame];
        sharingLabel.y += 11;
        sharingLabel.x += 15;
        sharingLabel.width -= 50;
        sharingLabel.text = NSLocalizedString(@"Paste on WhatsApp, Facebook & Twitter", @"");
        sharingLabel.textColor = [UIColor colorWithRed:141/255.f green:151/255.f blue:144/255.f alpha:1.00];
        sharingLabel.font = [UIFont fontWithName:kFontNameMedium size:14];
        [scrollView addSubview:sharingLabel];
        
        bottomRect = copyShareCodeButton.frame;
        
        if ([WhatsAppAPI isAvailable]) {
            [copyShareCodeButton setTitle:NSLocalizedString(@"Share on WhatsApp", @"") forState:UIControlStateNormal];
            sharingLabel.text = NSLocalizedString(@"And bring friends", @"");
            
            UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"whatsapp_icon_iphone"]];
            arrowImageView.center = CGPointMake(CGRectGetWidth(self.view.frame) - 40, CGRectGetMidY(copyShareCodeButton.frame));
            [scrollView addSubview:arrowImageView];
        } else {
            UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"goto"]];
            arrowImageView.center = CGPointMake(CGRectGetWidth(self.view.frame) - 20, CGRectGetMidY(copyShareCodeButton.frame));
            [scrollView addSubview:arrowImageView];
        }
    }
    
    if (!self.group.isDefault && FBTweakValue(@"UX", @"Group", @"Chat", YES)) {
        UIView *notificationsView = generateView(CGRectMake(0, CGRectGetMaxY(bottomRect) - 0.5, CGRectGetWidth(self.view.frame), 52));
        UIButton *notificationsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, notificationsView.y, 240, notificationsView.height)];
        [notificationsButton setTitle:NSLocalizedString(@"Notifications", @"") forState:UIControlStateNormal];
        [notificationsButton setTitleColor:[[UIColor ftb_cellMatchPotColor] colorWithAlphaComponent:1.0] forState:UIControlStateNormal];
        [notificationsButton setTitleColor:[[notificationsButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.2] forState:UIControlStateHighlighted];
        notificationsButton.titleLabel.font = [UIFont fontWithName:kFontNameMedium size:16];
        notificationsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        notificationsButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        notificationsButton.userInteractionEnabled = NO;
        [scrollView addSubview:notificationsButton];
		
		FTBUser *user = [FTBUser currentUser];
        self.notificationsSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, CGRectGetHeight(notificationsButton.frame))];
        self.notificationsSwitch.center = CGPointMake(CGRectGetWidth(self.view.frame) - 40, CGRectGetMidY(notificationsButton.frame));
        self.notificationsSwitch.on = user.isNotificationsEnabled;
        self.notificationsSwitch.onTintColor = [UIColor ftb_greenGrassColor];
        [self.notificationsSwitch addTarget:self action:@selector(notificationsSwitchValueChangedAction:) forControlEvents:UIControlEventValueChanged];
        [scrollView addSubview:self.notificationsSwitch];
        
        if (![self.group.members containsObject:user]) {
            self.notificationsSwitch.enabled = NO;
        }
		
		[[FTBClient client] group:self.group.identifier success:^(id object) {
			self.group = object;
            [self.notificationsSwitch setOn:user.isNotificationsEnabled animated:YES];
            self.notificationsSwitch.enabled = YES;
        } failure:nil];
        
        bottomRect = notificationsView.frame;
    }
    
    UIView *leaveGroupView = generateView(CGRectMake(0, CGRectGetMaxY(bottomRect) + 9, CGRectGetWidth(self.view.frame), 52));
    self.leaveGroupButton = [[UIButton alloc] initWithFrame:leaveGroupView.frame];
    [self.leaveGroupButton setTitle:NSLocalizedString(@"Leave group", @"") forState:UIControlStateNormal];
    [self.leaveGroupButton setTitleColor:[UIColor colorWithRed:216/255.f green:80./255.f blue:80./255.f alpha:1.00] forState:UIControlStateNormal];
    [self.leaveGroupButton setTitleColor:[[self.leaveGroupButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.2] forState:UIControlStateHighlighted];
    self.leaveGroupButton.titleLabel.font = [UIFont fontWithName:kFontNameMedium size:16];
    [self.leaveGroupButton addTarget:self action:@selector(leaveGroupAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.leaveGroupButton];
    
    scrollView.contentSize = CGSizeMake(scrollView.width, CGRectGetMaxY(leaveGroupView.frame) + 9);
    
    [self reloadData];
    
    self.groupImageButton.userInteractionEnabled = NO;
    if (!self.groupImageButton.imageView.image && !self.groupImageButton.userInteractionEnabled) {
        if (self.group.isWorld) {
            [self.groupImageButton setImage:[UIImage imageNamed:@"world_icon"] forState:UIControlStateNormal];
        } else if (self.group.isFriends) {
			[self.groupImageButton setImage:[UIImage imageNamed:@"icon-group-friends"] forState:UIControlStateNormal];
		} else {
            [self.groupImageButton setImage:[UIImage imageNamed:@"generic_group"] forState:UIControlStateNormal];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.nameTextField resignFirstResponder];
    [self updateGroupName];
}

@end
