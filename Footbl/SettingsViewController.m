//
//  SettingsViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/24/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

@import MessageUI;
#import <SPHipster/SPHipster.h>
#import "AuthenticationViewController.h"
#import "ChangePasswordViewController.h"
#import "FootblAPI.h"
#import "FootblNavigationController.h"
#import "EditProfileViewController.h"
#import "ImportImageHelper.h"
#import "LogsViewController.h"
#import "SettingsTableViewCell.h"
#import "SettingsTextViewController.h"
#import "SettingsViewController.h"
#import "TutorialViewController.h"
#import "User.h"

typedef NS_ENUM(NSInteger, SettingsType) {
    SettingsTypeTinyInfo,
    SettingsTypeInfo,
    SettingsTypeAction,
    SettingsTypeActionDestructive,
    SettingsTypeMore
};

@interface SettingsViewController () <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@end

#pragma mark SettingsViewController

@implementation SettingsViewController

NSString * const kSettingsDataSourceTitleKey = @"kSettingsDataSourceTitleKey";
NSString * const kSettingsDataSourceValueKey = @"kSettingsDataSourceValueKey";
NSString * const kSettingsDataSourceItemsKey = @"kSettingsDataSourceItemsKey";
NSString * const kSettingsDataSourceExtraKey = @"kSettingsDataSourceExtraKey";
NSString * const kSettingsDataSourceTypeKey = @"kSettingsDataSourceTypeKey";
NSString * const kChangelogUrlString = @"https://rink.hockeyapp.net/apps/5ab6b4328d609707f1f9eb28b90c61b6";

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (NSArray *)dataSource {
    if (!_dataSource) {
        NSMutableArray *licenses = [NSMutableArray new];
        NSArray *pods = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Pods-acknowledgements" ofType:@"plist"]][@"PreferenceSpecifiers"];
        for (NSInteger i = 0; i < [pods count] - 1; i++) {
            if (i == 0) {
                continue;
            }
            
            [licenses addObject:@{kSettingsDataSourceTitleKey : pods[i][@"Title"], kSettingsDataSourceExtraKey : pods[i][@"FooterText"], kSettingsDataSourceTypeKey : @(SettingsTypeInfo)}];
        }
        
        NSArray *aboutDataSource = @[@{kSettingsDataSourceTitleKey : @"",
                                       kSettingsDataSourceItemsKey : @[@{kSettingsDataSourceTitleKey : NSLocalizedString(@"Legal", @""),
                                                                         kSettingsDataSourceValueKey : @"",
                                                                         kSettingsDataSourceTypeKey : @(SettingsTypeAction),
                                                                         kSettingsDataSourceExtraKey : NSStringFromSelector(@selector(legalAction:))},
                                                                       @{kSettingsDataSourceTitleKey : NSLocalizedString(@"Licenses", @""),
                                                                         kSettingsDataSourceValueKey : @"",
                                                                         kSettingsDataSourceTypeKey : @(SettingsTypeMore),
                                                                         kSettingsDataSourceExtraKey : @[@{kSettingsDataSourceTitleKey : NSLocalizedString(@"Licenses", @""),
                                                                                                           kSettingsDataSourceItemsKey : licenses}]},
                                                                       @{kSettingsDataSourceTitleKey : NSLocalizedString(@"Version", @""),
                                                                         kSettingsDataSourceValueKey : SPGetApplicationVersion(),
                                                                         kSettingsDataSourceTypeKey : @(SettingsTypeTinyInfo)}
                                                                       ]}];
        
        NSArray *accountDataSource = @[@{kSettingsDataSourceTitleKey : @"",
                                         kSettingsDataSourceItemsKey : @[@{kSettingsDataSourceTitleKey : NSLocalizedString(@"Edit profile", @""),
                                                                           kSettingsDataSourceValueKey : @"",
                                                                           kSettingsDataSourceTypeKey : @(SettingsTypeAction),
                                                                           kSettingsDataSourceExtraKey : NSStringFromSelector(@selector(updateAccountAction:))},
                                                                         @{kSettingsDataSourceTitleKey : NSLocalizedString(@"Update profile picture", @""),
                                                                           kSettingsDataSourceValueKey : @"",
                                                                           kSettingsDataSourceTypeKey : @(SettingsTypeAction),
                                                                           kSettingsDataSourceExtraKey : NSStringFromSelector(@selector(updateProfilePictureAction:))},
                                                                         @{kSettingsDataSourceTitleKey : NSLocalizedString(@"Change password", @""),
                                                                           kSettingsDataSourceValueKey : @"",
                                                                           kSettingsDataSourceTypeKey : @(SettingsTypeAction),
                                                                           kSettingsDataSourceExtraKey : NSStringFromSelector(@selector(changePasswordAction:))}
                                                                         ]},
                                       @{kSettingsDataSourceTitleKey : @"",
                                         kSettingsDataSourceItemsKey : @[]},
                                       @{kSettingsDataSourceTitleKey : @"",
                                         kSettingsDataSourceItemsKey : @[@{kSettingsDataSourceTitleKey : NSLocalizedString(@"Delete account", @""),
                                                                           kSettingsDataSourceValueKey : @"",
                                                                           kSettingsDataSourceTypeKey : @(SettingsTypeActionDestructive),
                                                                           kSettingsDataSourceExtraKey : NSStringFromSelector(@selector(deleteAccountAction:))}]}
                                       ];
        
        _dataSource = @[@{kSettingsDataSourceTitleKey : @"",
                          kSettingsDataSourceItemsKey : @[@{kSettingsDataSourceTitleKey : NSLocalizedString(@"My Account", @""),
                                                            kSettingsDataSourceValueKey : @"",
                                                            kSettingsDataSourceTypeKey : @(SettingsTypeMore),
                                                            kSettingsDataSourceExtraKey : accountDataSource}
                                                          ]},
                        @{kSettingsDataSourceTitleKey : @"",
                          kSettingsDataSourceItemsKey : @[@{kSettingsDataSourceTitleKey : NSLocalizedString(@"Tell a friend", @""),
                                                            kSettingsDataSourceValueKey : @"",
                                                            kSettingsDataSourceTypeKey : @(SettingsTypeAction),
                                                            kSettingsDataSourceExtraKey : NSStringFromSelector(@selector(shareAction:))}
                                                          ]},
                        @{kSettingsDataSourceTitleKey : @"",
                          kSettingsDataSourceItemsKey : @[@{kSettingsDataSourceTitleKey : NSLocalizedString(@"About", @""),
                                                            kSettingsDataSourceValueKey : @"",
                                                            kSettingsDataSourceTypeKey : @(SettingsTypeMore),
                                                            kSettingsDataSourceExtraKey : aboutDataSource},
                                                          @{kSettingsDataSourceTitleKey : NSLocalizedString(@"Review on App Store", @""),
                                                            kSettingsDataSourceValueKey : @"",
                                                            kSettingsDataSourceTypeKey : @(SettingsTypeAction),
                                                            kSettingsDataSourceExtraKey : NSStringFromSelector(@selector(appStoreReviewAction:))},
                                                          @{kSettingsDataSourceTitleKey : NSLocalizedString(@"Support", @""),
                                                            kSettingsDataSourceValueKey : @"",
                                                            kSettingsDataSourceTypeKey : @(SettingsTypeAction),
                                                            kSettingsDataSourceExtraKey : NSStringFromSelector(@selector(supportAction:))},
                                                          @{kSettingsDataSourceTitleKey : NSLocalizedString(@"View tutorial", @""),
                                                            kSettingsDataSourceValueKey : @"",
                                                            kSettingsDataSourceTypeKey : @(SettingsTypeAction),
                                                            kSettingsDataSourceExtraKey : NSStringFromSelector(@selector(viewTutorialAction:))}
                                                          ]},
                        @{kSettingsDataSourceTitleKey : @"",
                          kSettingsDataSourceItemsKey : @[@{kSettingsDataSourceTitleKey : NSLocalizedString(@"Logout", @""),
                                                            kSettingsDataSourceValueKey : @"",
                                                            kSettingsDataSourceTypeKey : @(SettingsTypeActionDestructive),
                                                            kSettingsDataSourceExtraKey : NSStringFromSelector(@selector(logoutAction:))}
                                                          ]}];
        
        if (SPGetBuildType() != SPBuildTypeAppStore) {
            NSMutableArray *logs = [NSMutableArray new];
            NSString *logsFolder = SPLogFilePath();
            for (NSString *logFile in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:logsFolder error:nil]) {
                if ([logFile.lowercaseString rangeOfString:@"ds_store"].location != NSNotFound) {
                    continue;
                }
                [logs insertObject:@{kSettingsDataSourceTitleKey : logFile, kSettingsDataSourceTypeKey : @(SettingsTypeAction), kSettingsDataSourceExtraKey : NSStringFromSelector(@selector(openLogs:))} atIndex:0];
            }
            
            _dataSource = [_dataSource arrayByAddingObject:@{kSettingsDataSourceTitleKey : @"",
                                                             kSettingsDataSourceItemsKey : @[]}];
            _dataSource = [_dataSource arrayByAddingObject:@{kSettingsDataSourceTitleKey : @"",
                                                             kSettingsDataSourceItemsKey : @[@{kSettingsDataSourceTitleKey : @"Logs",
                                                                                               kSettingsDataSourceValueKey : @"",
                                                                                               kSettingsDataSourceTypeKey : @(SettingsTypeMore),
                                                                                               kSettingsDataSourceExtraKey : @[@{kSettingsDataSourceTitleKey : @"Logs",
                                                                                                                                 kSettingsDataSourceItemsKey : logs}]}]}];
        }
    }
    return _dataSource;
}

#pragma mark - Instance Methods

- (void)appStoreReviewAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"Sharing URL", @"")]];
}

- (void)changePasswordAction:(id)sender {
    ChangePasswordViewController *changePasswordViewController = [ChangePasswordViewController new];
    if ([FootblAPI sharedAPI].authenticationType == FootblAuthenticationTypeFacebook) {
        changePasswordViewController.oldPassword = @"";
    }
    changePasswordViewController.completionBlock = ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    FootblNavigationController *navigationViewController = [[FootblNavigationController alloc] initWithRootViewController:changePasswordViewController];
    [self presentViewController:navigationViewController animated:YES completion:nil];
}

- (void)legalAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"Legal URL", @"")]];
}

- (void)updateAccountAction:(id)sender {
    EditProfileViewController *editProfileViewController = [EditProfileViewController new];
    FootblNavigationController *navigationViewController = [[FootblNavigationController alloc] initWithRootViewController:editProfileViewController];
    [self presentViewController:navigationViewController animated:YES completion:nil];
}

- (void)updateProfilePictureAction:(id)sender {
    [[ImportImageHelper sharedInstance] importImageFromSources:@[@(ImportImageHelperSourceCamera), @(ImportImageHelperSourceLibrary), @(ImportImageHelperSourceFacebook)] completionBlock:^(UIImage *image, NSError *error) {
        if (image) {
            [[FootblAPI sharedAPI] updateAccountWithUsername:nil name:nil email:nil password:nil fbToken:nil profileImage:image about:nil success:nil failure:nil];
        }
    }];
}

- (void)deleteAccountAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry to see you go!", @"") message:NSLocalizedString(@"Are you sure you want to delete your account?", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"Delete Now", @""), nil];
    [alert show];
}

- (void)shareAction:(id)sender {
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:NSLocalizedString(@"Sharing URL", @"")], NSLocalizedString(@"Sharing text", @"")] applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypePostToFlickr, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)supportAction:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *picker = [MFMailComposeViewController new];
        [picker setMailComposeDelegate:self];
        [picker setToRecipients:@[NSLocalizedString(@"Support email recipient", @"")]];
        [picker setSubject:[NSString stringWithFormat:NSLocalizedString(@"Support email subject", @"{application name}"), SPGetApplicationName()]];
        [picker setMessageBody:[NSString stringWithFormat:NSLocalizedString(@"Support email body", @"{application name} {application version} {system version} {device model} {user identifier}"), SPGetApplicationName(), SPGetApplicationVersion(), [[UIDevice currentDevice] systemVersion], [[UIDevice currentDevice] model], [User currentUser].rid] isHTML:NO];
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Can't send email title", @"Can't send email title") message:NSLocalizedString(@"Can't send email message", @"Can't send email message") delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        [alert show];
    }
}

- (void)logoutAction:(id)sender {
    [[FootblAPI sharedAPI] logout];
}

- (void)openLogs:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    LogsViewController *textViewController = [LogsViewController new];
    textViewController.title = self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceTitleKey];
    NSString *text = [[NSString alloc] initWithContentsOfFile:[SPLogFilePath() stringByAppendingPathComponent:textViewController.title] encoding:NSUTF8StringEncoding error:nil];
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\n"];
    textViewController.text = text;
    [self.navigationController pushViewController:textViewController animated:YES];
}

- (void)viewTutorialAction:(id)sender {
    TutorialViewController *tutorialViewController = [TutorialViewController new];
    FootblNavigationController *tutorialNavigationController = [[FootblNavigationController alloc] initWithRootViewController:tutorialViewController];
    [self presentViewController:tutorialNavigationController animated:YES completion:^{
       [tutorialViewController.getStartedButton setTitle:NSLocalizedString(@"Close", @"") forState:UIControlStateNormal]; 
    }];
    [tutorialViewController setCompletionBlock:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - Delegates & Data sources

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[User currentUser] deleteWithSuccess:^{
            [self logoutAction:nil];
        } failure:[ErrorHandler failureBlock]];
    }
}

#pragma mark - MFMailComposeViewController delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource[section][kSettingsDataSourceItemsKey] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell" forIndexPath:indexPath];
    cell.infoLabel.text = self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceTitleKey];
    cell.infoLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.text = self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceValueKey];
    cell.infoLabel.textAlignment = NSTextAlignmentLeft;
    cell.infoLabel.textColor = [[FootblAppearance colorForView:FootblColorCellMatchPot] colorWithAlphaComponent:1.0];
    cell.infoLabel.font = [UIFont fontWithName:kFontNameMedium size:17];
    
    switch ((SettingsType)[self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceTypeKey] integerValue]) {
        case SettingsTypeMore:
        case SettingsTypeInfo:
        case SettingsTypeAction:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case SettingsTypeActionDestructive:
            cell.infoLabel.textAlignment = NSTextAlignmentCenter;
            cell.infoLabel.textColor = [UIColor colorWithRed:216/255.f green:80./255.f blue:80./255.f alpha:1.00];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        default:
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = self.dataSource[section][kSettingsDataSourceTitleKey];
    if ([title isEqualToString:self.title]) {
        return @"";
    } else {
        return title;
    }
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ((SettingsType)[self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceTypeKey] integerValue]) {
        case SettingsTypeMore: {
            SettingsViewController *settingsViewController = [SettingsViewController new];
            settingsViewController.title = self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceTitleKey];
            settingsViewController.dataSource = self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceExtraKey];
            [self.navigationController pushViewController:settingsViewController animated:YES];
            break;
        }
        case SettingsTypeInfo: {
            SettingsTextViewController *textViewController = [SettingsTextViewController new];
            textViewController.title = self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceTitleKey];
            textViewController.text = self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceExtraKey];
            [self.navigationController pushViewController:textViewController animated:YES];
            break;
        }
        case SettingsTypeAction:
        case SettingsTypeActionDestructive: {
            SettingsViewController *settingsViewController = [SettingsViewController new];
            settingsViewController.title = self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceTitleKey];
            SEL selector = NSSelectorFromString(self.dataSource[indexPath.section][kSettingsDataSourceItemsKey][indexPath.row][kSettingsDataSourceExtraKey]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:selector withObject:[tableView cellForRowAtIndexPath:indexPath]];
#pragma clang diagnostic pop
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        }
        default:
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
    }
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    if (self.title.length == 0) {
        self.title = NSLocalizedString(@"Settings", @"Settings");
    }
    
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.83 alpha:1];
    [self.tableView registerClass:[SettingsTableViewCell class] forCellReuseIdentifier:@"SettingsCell"];
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.tableView.indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
