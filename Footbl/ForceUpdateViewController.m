//
//  ForceUpdateViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/23/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "ForceUpdateViewController.h"
#import "NSParagraphStyle+AlignmentCenter.h"
#import "UIImage+Color.h"

@interface ForceUpdateViewController ()

@end

#pragma mark ForceUpdateViewController

@implementation ForceUpdateViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (IBAction)appStoreAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"Sharing URL", @"")]];
}

#pragma mark - Delegates & Data sources

#pragma mark - View Lifecycle

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)loadView {
    [super loadView];
    
    UIView *greenView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 164)];
    greenView.backgroundColor = [UIColor colorWithRed:0.2 green:0.81 blue:0.48 alpha:1];
    greenView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:greenView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(greenView.frame) - 20, CGRectGetHeight(greenView.frame))];
    titleLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:24];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"Update available!", @"");
    titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:titleLabel];
    
    UIImageView *footblImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"footbl_circle"]];
    footblImageView.center = CGPointMake(CGRectGetMidX(greenView.frame), CGRectGetMaxY(greenView.frame));
    [self.view addSubview:footblImageView];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(footblImageView.frame), CGRectGetWidth(greenView.frame) - 20, 192)];
    textLabel.numberOfLines = 0;
    [self.view addSubview:textLabel];
    
    NSString *text = NSLocalizedString(@"Update available text", @"");
    NSString *header = @"";
    if ([text rangeOfString:@"\n"].location != NSNotFound) {
        header = [text componentsSeparatedByString:@"\n"].firstObject;
        text = [@"\n" stringByAppendingString:[text componentsSeparatedByString:@"\n"].lastObject];
    }
    UIColor *color = [[FootblAppearance colorForView:FootblColorCellMatchPot] colorWithAlphaComponent:1.0];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultCenterAlignmentParagraphStyle] mutableCopy];
    paragraphStyle.lineHeightMultiple = 0.85;
    
    NSMutableDictionary *headerStyle = [@{NSParagraphStyleAttributeName: paragraphStyle,
                                          NSFontAttributeName : [UIFont fontWithName:kFontNameAvenirNextDemiBold size:18],
                                          NSForegroundColorAttributeName : color} mutableCopy];
    NSMutableDictionary *textStyle = [@{NSParagraphStyleAttributeName: paragraphStyle,
                                        NSFontAttributeName : [UIFont fontWithName:kFontNameAvenirNextRegular size:18],
                                        NSForegroundColorAttributeName : color} mutableCopy];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:header attributes:headerStyle];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:text attributes:textStyle]];
    textLabel.attributedText = attributedString;
    
    UIButton *updateButton = [[UIButton alloc] initWithFrame:CGRectMake(24, 407, CGRectGetWidth(self.view.frame) - 48, 51)];
    updateButton.clipsToBounds = YES;
    updateButton.layer.cornerRadius = 5;
    updateButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    updateButton.titleLabel.font = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:16];
    updateButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 38);
    updateButton.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [updateButton setBackgroundImage:[UIImage imageWithColor:greenView.backgroundColor] forState:UIControlStateNormal];
    [updateButton setImage:[UIImage imageNamed:@"btn_update_appstore"] forState:UIControlStateNormal];
    [updateButton setImage:[updateButton imageForState:UIControlStateNormal] forState:UIControlStateHighlighted];
    [updateButton setTitle:NSLocalizedString(@"Update on App Store", @"") forState:UIControlStateNormal];
    [updateButton addTarget:self action:@selector(appStoreAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:updateButton];
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
