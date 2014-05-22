//
//  GroupInfoViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/2/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIButton+WebCache.h>
#import "Championship.h"
#import "Group.h"
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
    
    UIView * (^generateView)(CGRect frame) = ^(CGRect frame) {
        frame.origin.x -= 1;
        frame.size.width += 2;
        UIView *view = [[UIView alloc] initWithFrame:frame];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.borderColor = [UIColor colorWithRed:227/255.f green:232/255.f blue:228/255.f alpha:1.00].CGColor;
        view.layer.borderWidth = 0.5;
        [self.view addSubview:view];
        return view;
    };
    
    UIView *championshipView = generateView(CGRectMake(0, 232, CGRectGetWidth(self.view.frame), 62));
    self.championshipLabel = [[UILabel alloc] initWithFrame:championshipView.frame];
    self.championshipLabel.numberOfLines = 2;
    [self.view addSubview:self.championshipLabel];
    
    UIView *leaveGroupView = generateView(CGRectMake(0, CGRectGetMaxY(championshipView.frame) + 88, CGRectGetWidth(self.view.frame), 62));
    self.leaveGroupButton = [[UIButton alloc] initWithFrame:leaveGroupView.frame];
    [self.leaveGroupButton setTitle:NSLocalizedString(@"Leave group", @"") forState:UIControlStateNormal];
    [self.leaveGroupButton setTitleColor:[UIColor colorWithRed:216/255.f green:80./255.f blue:80./255.f alpha:1.00] forState:UIControlStateNormal];
    [self.leaveGroupButton setTitleColor:[[self.leaveGroupButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.2] forState:UIControlStateHighlighted];
    self.leaveGroupButton.titleLabel.font = [UIFont fontWithName:kFontNameMedium size:16];
    [self.leaveGroupButton addTarget:self action:@selector(leaveGroupAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.leaveGroupButton];
    
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
