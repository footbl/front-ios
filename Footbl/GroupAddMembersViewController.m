//
//  GroupAddMembersViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/3/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <APAddressBook/APAddressBook.h>
#import <APAddressBook/APContact.h>
#import <FacebookSDK/FacebookSDK.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SPHipster/SPHipster.h>
#import <UIAlertView-Blocks/UIAlertView+Blocks.h>
#import "FriendsHelper.h"
#import "Group.h"
#import "GroupAddMembersViewController.h"
#import "GroupAddMemberTableViewCell.h"
#import "LoadingHelper.h"
#import "WhatsAppAPI.h"

@interface GroupAddMembersViewController ()

@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSArray *addressBookDataSource;
@property (strong, nonatomic) NSArray *facebookDataSource;
@property (strong, nonatomic) NSArray *footblDataSource;
@property (strong, nonatomic) NSMutableSet *selectedMembers;
@property (strong, nonatomic) NSMutableSet *footblSelectedMembers;
@property (strong, nonatomic) NSMutableSet *facebookSelectedMembers;
@property (strong, nonatomic) NSMutableSet *addressBookSelectedMembers;

@end

#pragma mark GroupAddMembersViewController

@implementation GroupAddMembersViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

@synthesize dataSource = _dataSource;

- (NSArray *)addressBookDataSource {
    if (!_addressBookDataSource) {
        _addressBookDataSource = @[];
        
        APAddressBook *addressBook = [APAddressBook new];
        addressBook.fieldsMask = APContactFieldEmails | APContactFieldFirstName | APContactFieldLastName | APContactFieldThumbnail | APContactFieldCompositeName;
        addressBook.filterBlock = ^BOOL(APContact *contact) {
            if (contact.emails.count == 0 && contact.firstName.length == 0 && contact.lastName.length == 0) {
                return NO;
            }
            
            if (self.group) {
                if ([[self.group.members filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"user.email IN %@", contact.emails]] count] > 0) {
                    return NO;
                }
            }
            return YES;
        };
        addressBook.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        [addressBook loadContacts:^(NSArray *contacts, NSError *error) {
            self.addressBookDataSource = contacts;
            self.dataSource = contacts;
            if (self.searchBar.text.length > 0) {
                [self searchBar:self.searchBar textDidChange:self.searchBar.text];
            }
            [self.tableView reloadData];
            [self reloadFootblFriends];
        }];
    }
    
    return _addressBookDataSource;
}

- (NSArray *)facebookDataSource {
    if (!_facebookDataSource) {
        _facebookDataSource = @[];
        
        [[FootblAPI sharedAPI] authenticateFacebookWithCompletion:^(FBSession *session, FBSessionState status, NSError *error) {
            [[FriendsHelper sharedInstance] getFbInvitableFriendsWithCompletionBlock:^(NSArray *friends, NSError *error) {
                if (error) {
                    SPLogError(@"Facebook error %@, %@", error, [error userInfo]);
                    [[ErrorHandler sharedInstance] displayError:error];
                } else {
                    self.facebookDataSource = friends;
                    self.dataSource = nil;
                    [self.tableView reloadData];
                    [self reloadFootblFriends];
                }
            }];
        }];
    }
    
    return _facebookDataSource;
}

- (NSArray *)footblDataSource {
    if (!_footblDataSource) {
        _footblDataSource = @[];
        
        [[FriendsHelper sharedInstance] getFriendsWithCompletionBlock:^(NSArray *friends, NSError *error) {
            self.footblDataSource = friends;
            self.dataSource = nil;
            [self.tableView reloadData];
        }];
    }
    
    return _footblDataSource;
}

- (NSArray *)dataSource {
    if (!self.segmentedControl) {
        return @[];
    }
    
    if (!_dataSource) {
        switch (self.segmentedControl.selectedSegmentIndex) {
            case 0:
                self.dataSource = self.footblDataSource;
                break;
            case 1:
                self.dataSource = self.addressBookDataSource;
                break;
            default:
                self.dataSource = self.facebookDataSource;
                break;
        }
    }
    
    return _dataSource;
}

- (void)setDataSource:(NSArray *)dataSource {
    if (!self.group) {
        _dataSource = dataSource;
        return;
    }
    
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            _dataSource = [dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (_id IN %@)", [[self.group.members valueForKeyPath:@"user"] valueForKeyPath:@"rid"]]];
            break;
        case 1:
            _dataSource = dataSource;
            break;
        default:
            _dataSource = dataSource;
            break;
    }
}

#pragma mark - Instance Methods

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)segmentedControlAction:(id)sender {
    self.dataSource = nil;
    if (self.searchBar.text.length > 0) {
        [self searchBar:self.searchBar textDidChange:self.searchBar.text];
    }
    [self.searchBar resignFirstResponder];
    [self.tableView reloadData];
}

- (void)configureCell:(GroupAddMemberTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [cell restoreFrames];
    
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            cell.usernameLabel.text = self.dataSource[indexPath.row][@"username"];
            cell.nameLabel.text = self.dataSource[indexPath.row][@"name"];
            [cell.profileImageView setImageWithURL:[NSURL URLWithString:self.dataSource[indexPath.row][@"picture"]] placeholderImage:cell.placeholderImage];
            break;
        case 1: {
            APContact *contact = self.dataSource[indexPath.row];
            if (contact.firstName.length > 0 && contact.lastName.length > 0) {
                cell.usernameLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
            } else if (contact.firstName.length > 0) {
                cell.usernameLabel.text = contact.firstName;
            } else {
                cell.usernameLabel.text = contact.lastName;
            }
            cell.nameLabel.text = contact.emails.firstObject;
            if (contact.thumbnail) {
                cell.profileImageView.image = contact.thumbnail;
            } else {
                [cell.profileImageView cancelCurrentImageLoad];
                [cell restoreProfileImagePlaceholder];
            }
            break;
        }
        case 2:
            cell.usernameLabel.text = self.dataSource[indexPath.row][@"name"];
            CGRect usernameFrame = cell.usernameLabel.frame;
            usernameFrame.origin.y += 8;
            cell.usernameLabel.frame = usernameFrame;
            cell.nameLabel.text = @"";
            if ([self.dataSource[indexPath.row][@"picture"][@"data"][@"is_silhouette"] boolValue]) {
                [cell.profileImageView cancelCurrentImageLoad];
                [cell restoreProfileImagePlaceholder];
            } else {
                [cell.profileImageView setImageWithURL:[NSURL URLWithString:self.dataSource[indexPath.row][@"picture"][@"data"][@"url"]] placeholderImage:cell.placeholderImage];
            }
            break;
        default:
            break;
    }
    
    if ([self.selectedMembers containsObject:self.dataSource[indexPath.row]] && ![[self.tableView indexPathsForSelectedRows] containsObject:indexPath]) {
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (IBAction)createAction:(id)sender {
    self.view.window.userInteractionEnabled = NO;
    
    FootblAPIFailureBlock failureBlock = ^(NSError *error) {
        [[LoadingHelper sharedInstance] hideHud];
        [[ErrorHandler sharedInstance] displayError:error];
        self.view.window.userInteractionEnabled = YES;
    };
    
    void(^whatsAppBlock)(Group *group) = ^(Group *group) {
        if ([self.group.rid isEqualToString:group.rid] || ![WhatsAppAPI isAvailable]) {
            return;
        }
        
        RIButtonItem *shareItem = [RIButtonItem itemWithLabel:NSLocalizedString(@"Sure", @"") action:^{
            [WhatsAppAPI shareText:group.sharingText];
        }];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Share %@ on WhatsApp and bring friends!", @"Share {group_name} on WhatsApp"), group.name] message:nil cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"Not now", @"")] otherButtonItems:shareItem, nil];
        [alertView show];
    };
    
    void(^successBlock)(Group *group) = ^(Group *group) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
            self.view.window.userInteractionEnabled = YES;
            [[LoadingHelper sharedInstance] hideHud];
            
            if (self.facebookSelectedMembers.count > 0) {
                NSMutableDictionary *fbParamsDictionary = [NSMutableDictionary new];
                [[self.facebookSelectedMembers.allObjects valueForKeyPath:@"id"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    fbParamsDictionary[[NSString stringWithFormat:@"to[%lu]", (unsigned long)idx]] = obj;
                }];
                
                [FBWebDialogs presentRequestsDialogModallyWithSession:[FBSession activeSession] message:NSLocalizedString(@"Facebook group invitation message", @"") title:NSLocalizedString(@"Facebook group invitation title", @"") parameters:fbParamsDictionary handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                    if (error) {
                        SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
                    }
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (float)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        whatsAppBlock(group);
                    });
                }];
            } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (float)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    whatsAppBlock(group);
                });
            }
        });
    };
    
    NSMutableArray *invitedMembers = [NSMutableArray new];
    [invitedMembers addObjectsFromArray:self.facebookSelectedMembers.allObjects];
    for (APContact *contact in self.addressBookSelectedMembers) {
        [invitedMembers addObjectsFromArray:contact.emails];
    }
    
    [[LoadingHelper sharedInstance] showHud];
    if (self.group) {
        [self.group.editableObject addMembers:self.footblSelectedMembers.allObjects success:^{
            [self.group.editableObject addInvitedMembers:invitedMembers success:^{
                [self.group.editableObject updateMembersWithSuccess:^(id response) {
                    successBlock(self.group);
                } failure:^(NSError *error) {
                    successBlock(self.group);
                }];
            } failure:failureBlock];
        } failure:failureBlock];
    } else {
        [Group createWithChampionship:self.championship name:self.groupName image:self.groupImage members:self.footblSelectedMembers.allObjects invitedMembers:invitedMembers success:successBlock failure:failureBlock];
    }
}

- (void)reloadFootblFriends {
    [[FriendsHelper sharedInstance] reloadFriendsWithCompletionBlock:^(NSArray *friends, NSError *error) {
        self.footblDataSource = friends;
        self.dataSource = nil;
        [self.tableView reloadData];
    }];
}

#pragma mark - Delegates & Data sources

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (GroupAddMemberTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupAddMemberTableViewCell *cell = (GroupAddMemberTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupMemberCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.selectedMembers addObject:self.dataSource[indexPath.row]];
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            [self.footblSelectedMembers addObject:self.dataSource[indexPath.row]];
            break;
        case 1:
            [self.addressBookSelectedMembers addObject:self.dataSource[indexPath.row]];
            break;
        case 2:
            [self.facebookSelectedMembers addObject:self.dataSource[indexPath.row]];
            break;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.selectedMembers removeObject:self.dataSource[indexPath.row]];
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            [self.footblSelectedMembers removeObject:self.dataSource[indexPath.row]];
            break;
        case 1:
            [self.addressBookSelectedMembers removeObject:self.dataSource[indexPath.row]];
            break;
        case 2:
            [self.facebookSelectedMembers removeObject:self.dataSource[indexPath.row]];
            break;
    }
}

#pragma mark - UISearchBar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString *text = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0) {
        self.dataSource = nil;
    } else {
        switch (self.segmentedControl.selectedSegmentIndex) {
            case 0:
                self.dataSource = [self.footblDataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] %@ OR username BEGINSWITH[cd] %@", text, text]];
                break;
            case 1:
                self.dataSource = [self.addressBookDataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"firstName BEGINSWITH[cd] %@ OR lastName BEGINSWITH[cd] %@", text, text]];
                break;
            case 2:
                self.dataSource = [self.facebookDataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"first_name BEGINSWITH[cd] %@ OR last_name BEGINSWITH[cd] %@", text, text]];
                break;
            default:
                break;
        }
    }
    [self.tableView reloadData];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
    
    if (scrollView.contentOffset.y > -18) {
        self.separatorView.alpha = 1;
    } else {
        self.separatorView.alpha = 0;
    }
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Add members", @"");
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Create", @"") style:UIBarButtonItemStylePlain target:self action:@selector(createAction:)];
        
    self.selectedMembers = [NSMutableSet new];
    self.addressBookSelectedMembers = [NSMutableSet new];
    self.footblSelectedMembers = [NSMutableSet new];
    self.facebookSelectedMembers = [NSMutableSet new];
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Footbl", @"").lowercaseString, NSLocalizedString(@"Contacts", @""), NSLocalizedString(@"Facebook", @"")]];
    self.segmentedControl.frame = CGRectMake(15, 73, CGRectGetWidth(self.view.frame) - 30, 29);
    self.segmentedControl.tintColor = [FootblAppearance colorForView:FootblColorTabBarTint];
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.backgroundColor = self.view.backgroundColor;
    [self.segmentedControl addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentedControl];
    
    self.segmentedControlBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 47)];
    self.segmentedControlBackgroundView.backgroundColor = self.segmentedControl.backgroundColor;
    [self.view insertSubview:self.segmentedControlBackgroundView belowSubview:self.segmentedControl];
    
    self.separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 111, CGRectGetWidth(self.view.frame), 0.5)];
    self.separatorView.backgroundColor = [FootblAppearance colorForView:FootblColorCellSeparator];
    [self.view insertSubview:self.separatorView belowSubview:self.segmentedControlBackgroundView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 47, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 47)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = 66;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.clipsToBounds = YES;
    [self.tableView registerClass:[GroupAddMemberTableViewCell class] forCellReuseIdentifier:@"GroupMemberCell"];
    [self.view insertSubview:self.tableView belowSubview:self.separatorView];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 46, CGRectGetWidth(self.view.frame), 47)];
    self.searchBar.barTintColor = [UIColor whiteColor];
    self.searchBar.backgroundColor = [UIColor colorWithRed:0.84 green:0.87 blue:0.85 alpha:1];
    self.searchBar.clipsToBounds = YES;
    self.searchBar.placeholder = NSLocalizedString(@"Type a friend's name", @"");
    self.searchBar.delegate = self;
    self.searchBar.backgroundImage = [UIImage new];
    self.tableView.tableHeaderView = self.searchBar;
    
    for (UITextField *textField in [self.searchBar.subviews.firstObject subviews]) {
        if ([textField isKindOfClass:[UITextField class]]) {
            textField.textColor = [UIColor colorWithRed:0.56 green:0.56 blue:0.58 alpha:1];
            textField.backgroundColor = [UIColor whiteColor];
        }
    }
    
    if (self.group) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(createAction:)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
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
