//
//  GroupInfoViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/2/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIButton+WebCache.h>
#import "Championship.h"
#import "FootblNavigationController.h"
#import "Group.h"
#import "GroupAddMembersViewController.h"
#import "GroupInfoViewController.h"
#import "ImportImageHelper.h"
#import "UIView+Frame.h"
#import "UIView+Shake.h"
#import "User.h"

@interface GroupInfoViewController ()

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
            [self.group uploadImage:image success:nil failure:nil];
        }
        if (keyboardIsFirstResponder) {
            [self.nameTextField becomeFirstResponder];
        }
    }];
}

- (IBAction)leaveGroupAction:(id)sender {
    [self.group.editableObject deleteWithSuccess:nil failure:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)addNewMembersAction:(id)sender {
    GroupAddMembersViewController *groupAddMembersViewController = [GroupAddMembersViewController new];
    groupAddMembersViewController.group = self.group;
    FootblNavigationController *navigationController = [[FootblNavigationController alloc] initWithRootViewController:groupAddMembersViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)freeToEditSwitchValueChangedAction:(UISwitch *)switchView {
    switchView.userInteractionEnabled = NO;
    self.group.editableObject.freeToEdit = @(switchView.isOn);
    [self.group.editableObject saveWithSuccess:^{
        switchView.userInteractionEnabled = YES;
    } failure:^(NSError *error) {
        switchView.userInteractionEnabled = YES;
        [switchView setOn:!switchView.isOn animated:YES];
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
            [alert show];
        }
    }];
}

- (void)updateGroupName {
    if (![self.nameTextField.text isEqualToString:self.group.name] && [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        self.group.editableObject.name = self.nameTextField.text;
        [self.group.editableObject saveWithSuccess:nil failure:nil];
    }
}

- (void)dismissKeyboardGesture:(UITapGestureRecognizer *)gestureRecognizer {
    [self.nameTextField resignFirstResponder];
    [self updateGroupName];
}

- (void)reloadData {
    [super reloadData];
    
    self.nameTextField.text = self.group.name;
    self.nameTextField.userInteractionEnabled = (self.group.freeToEditValue || [self.group.owner.rid isEqualToString:[User currentUser].rid]);
    [self.groupImageButton setImageWithURL:[NSURL URLWithString:self.group.picture] forState:UIControlStateNormal];
    
    NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
    NSString *championshipName = self.group.championship.displayName;
    if (!championshipName) {
        championshipName = @"";
    }
    NSString *location = self.group.championship.displayCountry;
    if (self.group.championship.edition) {
        location = [location stringByAppendingFormat:@", %@", self.group.championship.edition.stringValue];
    }
    
    if (!location) {
        location = @"";
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSMutableDictionary *championshipTextAttributes = [@{NSFontAttributeName : [UIFont fontWithName:kFontNameMedium size:16],
                                                         NSParagraphStyleAttributeName : paragraphStyle} mutableCopy];
    championshipTextAttributes[NSForegroundColorAttributeName] = [[FootblAppearance colorForView:FootblColorCellMatchPot] colorWithAlphaComponent:1.0];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:championshipName attributes:championshipTextAttributes]];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    championshipTextAttributes[NSForegroundColorAttributeName] = [UIColor colorWithRed:141/255.f green:151/255.f blue:144/255.f alpha:1.00];
    
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:location attributes:championshipTextAttributes]];
    
    self.championshipLabel.attributedText = attributedString;
}

#pragma mark - Delegates & Data sources

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [super textFieldDidBeginEditing:textField];

    [self updateGroupName];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        [textField resignFirstResponder];
        [self updateGroupName];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
 
    self.title = NSLocalizedString(@"Group Info", @"");

    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardGesture:)]];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    for (UIView *view in self.view.subviews) {
        if (view == scrollView) {
            continue;
        }
        [scrollView addSubview:view];
        view.frameY -= 64;
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
    
    UIView *championshipView = generateView(CGRectMake(0, 168, CGRectGetWidth(self.view.frame), 62));
    self.championshipLabel = [[UILabel alloc] initWithFrame:championshipView.frame];
    self.championshipLabel.numberOfLines = 2;
    [scrollView addSubview:self.championshipLabel];
    
    CGRect bottomRect = championshipView.frame;
    if (self.group.owner.isMe || self.group.freeToEditValue) {
        UIView *addNewMembersView = generateView(CGRectMake(0, CGRectGetMaxY(championshipView.frame) + 9, CGRectGetWidth(self.view.frame), 52));
        self.addNewMembersGroupButton = [[UIButton alloc] initWithFrame:addNewMembersView.frame];
        [self.addNewMembersGroupButton setTitle:NSLocalizedString(@"Add new members", @"") forState:UIControlStateNormal];
        [self.addNewMembersGroupButton setTitleColor:[[FootblAppearance colorForView:FootblColorCellMatchPot] colorWithAlphaComponent:1.0] forState:UIControlStateNormal];
        [self.addNewMembersGroupButton setTitleColor:[[self.addNewMembersGroupButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.2] forState:UIControlStateHighlighted];
        self.addNewMembersGroupButton.titleLabel.font = [UIFont fontWithName:kFontNameMedium size:16];
        self.addNewMembersGroupButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.addNewMembersGroupButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        [self.addNewMembersGroupButton addTarget:self action:@selector(addNewMembersAction:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:self.addNewMembersGroupButton];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"goto"]];
        arrowImageView.center = CGPointMake(CGRectGetWidth(self.view.frame) - 20, CGRectGetMidY(self.addNewMembersGroupButton.frame));
        [scrollView addSubview:arrowImageView];
        
        bottomRect = addNewMembersView.frame;
        
        if (self.group.owner.isMe) {
            UIView *freeToEditView = generateView(CGRectMake(0, CGRectGetMaxY(addNewMembersView.frame) - 0.5, CGRectGetWidth(self.view.frame), 52));
            UIButton *freeToEditButton = [[UIButton alloc] initWithFrame:CGRectMake(0, freeToEditView.frameY, 240, freeToEditView.frameHeight)];
            [freeToEditButton setTitle:NSLocalizedString(@"Anyone can add members", @"") forState:UIControlStateNormal];
            [freeToEditButton setTitleColor:[[FootblAppearance colorForView:FootblColorCellMatchPot] colorWithAlphaComponent:1.0] forState:UIControlStateNormal];
            [freeToEditButton setTitleColor:[[freeToEditButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.2] forState:UIControlStateHighlighted];
            freeToEditButton.titleLabel.font = [UIFont fontWithName:kFontNameMedium size:16];
            freeToEditButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            freeToEditButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
            freeToEditButton.userInteractionEnabled = NO;
            [scrollView addSubview:freeToEditButton];
            
            UISwitch *freeToEditSwich = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, CGRectGetHeight(freeToEditButton.frame))];
            freeToEditSwich.center = CGPointMake(CGRectGetWidth(self.view.frame) - 40, CGRectGetMidY(freeToEditButton.frame));
            freeToEditSwich.on = self.group.freeToEditValue;
            freeToEditSwich.onTintColor = [UIColor ftGreenGrassColor];
            [freeToEditSwich addTarget:self action:@selector(freeToEditSwitchValueChangedAction:) forControlEvents:UIControlEventValueChanged];
            [scrollView addSubview:freeToEditSwich];
            
            bottomRect = freeToEditView.frame;
        }
    }
    
    UIView *leaveGroupView = generateView(CGRectMake(0, CGRectGetMaxY(bottomRect) + 9, CGRectGetWidth(self.view.frame), 52));
    self.leaveGroupButton = [[UIButton alloc] initWithFrame:leaveGroupView.frame];
    [self.leaveGroupButton setTitle:NSLocalizedString(@"Leave group", @"") forState:UIControlStateNormal];
    [self.leaveGroupButton setTitleColor:[UIColor colorWithRed:216/255.f green:80./255.f blue:80./255.f alpha:1.00] forState:UIControlStateNormal];
    [self.leaveGroupButton setTitleColor:[[self.leaveGroupButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.2] forState:UIControlStateHighlighted];
    self.leaveGroupButton.titleLabel.font = [UIFont fontWithName:kFontNameMedium size:16];
    [self.leaveGroupButton addTarget:self action:@selector(leaveGroupAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.leaveGroupButton];
    
    scrollView.contentSize = CGSizeMake(scrollView.frameWidth, CGRectGetMaxY(leaveGroupView.frame) + 9);
    
    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self reloadData];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.nameTextField resignFirstResponder];
    [self updateGroupName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
