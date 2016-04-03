//
//  EditProfileViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/26/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "EditProfileViewController.h"
#import "FTBClient.h"
#import "FTBUser.h"
#import "LoadingHelper.h"
#import "NSString+Validations.h"
#import "UILabel+Shake.h"

@interface EditProfileViewController ()

@end

#pragma mark EditProfileViewController

@implementation EditProfileViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveAction:(id)sender {
    self.view.userInteractionEnabled = NO;
    [[LoadingHelper sharedInstance] showHud];
	
    [[FTBClient client] updateUsername:nil name:self.nameTextField.text email:nil password:nil fbToken:nil apnsToken:nil image:nil about:self.aboutMeTextView.text success:^(id object) {
		[[LoadingHelper sharedInstance] hideHud];
		[self dismissViewControllerAnimated:YES completion:nil];
	} failure:^(NSError *error) {
		[[LoadingHelper sharedInstance] hideHud];
		self.view.userInteractionEnabled = YES;
		[[ErrorHandler sharedInstance] displayError:error];
	}];
}

- (void)reloadData {
    [super reloadData];
    
    self.navigationItem.rightBarButtonItem.enabled = self.nameTextField.text.isValidName && self.aboutMeTextView.text.isValidAboutMe;
}

#pragma mark - Delegates & Data sources

#pragma mark - UITextField delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (!textField.text.isValidName) {
        [textField shakeAndChangeColor];
        return NO;
    }
    
    [self.aboutMeTextView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1];
    
    return YES;
}

#pragma mark - UITextView delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if (self.nameTextField.text.isValidName) {
            [self saveAction:textView];
        } else {
            [self.nameTextField becomeFirstResponder];
        }
        return NO;
    }
    
    if (![[textView.text stringByReplacingCharactersInRange:range withString:text] isValidAboutMe]) {
        [textView shakeAndChangeColor];
        return NO;
    }
    
    self.placeholderTextView.hidden = ([textView.text stringByReplacingCharactersInRange:range withString:text].length > 0);
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
	
	FTBUser *user = [FTBUser currentUser];
	
    self.title = NSLocalizedString(@"Edit profile", @"");
    self.view.backgroundColor = [UIColor ftb_viewMatchBackgroundColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveAction:)];
    
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
    
    CGRect nameFrame = CGRectMake(0, 84, CGRectGetWidth(self.view.frame), 62);
    generateView(nameFrame);
    self.nameTextField = [[UITextField alloc] initWithFrame:nameFrame];
    self.nameTextField.font = [UIFont fontWithName:kFontNameLight size:24];
    self.nameTextField.textAlignment = NSTextAlignmentCenter;
    self.nameTextField.textColor = [[UIColor ftb_cellMatchPotColor] colorWithAlphaComponent:1.0];
    self.nameTextField.delegate = self;
    self.nameTextField.enablesReturnKeyAutomatically = YES;
    self.nameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.nameTextField.autocorrectionType = UITextAutocorrectionTypeDefault;
    self.nameTextField.text = user.name;
    self.nameTextField.placeholder = NSLocalizedString(@"Name", @"");
    [self.nameTextField becomeFirstResponder];
    [self.view addSubview:self.nameTextField];
    
    CGRect aboutFrame = CGRectMake(0, CGRectGetMaxY(nameFrame) + 20, CGRectGetWidth(nameFrame), 72);
    generateView(aboutFrame);
    aboutFrame.origin.x += 5;
    aboutFrame.size.width -= 10;
    aboutFrame.origin.y += 5;
    aboutFrame.size.height -= 10;
    self.aboutMeTextView = [[UITextView alloc] initWithFrame:aboutFrame];
    self.aboutMeTextView.delegate = self;
    self.aboutMeTextView.enablesReturnKeyAutomatically = NO;
    self.aboutMeTextView.textColor = [[UIColor ftb_cellMatchPotColor] colorWithAlphaComponent:1.0];
    self.aboutMeTextView.font = [UIFont fontWithName:kFontNameMedium size:16];
    self.aboutMeTextView.text = user.about;
    self.aboutMeTextView.returnKeyType = UIReturnKeyDone;
    self.aboutMeTextView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    self.aboutMeTextView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.aboutMeTextView];
    
    self.placeholderTextView = [[UITextView alloc] initWithFrame:aboutFrame];
    self.placeholderTextView.textColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.8 alpha:1];
    self.placeholderTextView.font = [UIFont fontWithName:kFontNameMedium size:16];
    self.placeholderTextView.text = NSLocalizedString(@"About me", @"");
    self.placeholderTextView.backgroundColor = [UIColor clearColor];
    self.placeholderTextView.userInteractionEnabled = NO;
    [self.view addSubview:self.placeholderTextView];
    
    if (self.aboutMeTextView.text.length > 0) {
        self.placeholderTextView.hidden = YES;
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
