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
#import "Group.h"
#import "GroupAddMembersViewController.h"
#import "GroupAddMemberTableViewCell.h"

@interface GroupAddMembersViewController ()

@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSArray *addressBookDataSource;
@property (strong, nonatomic) NSArray *facebookDataSource;
@property (strong, nonatomic) NSArray *footblDataSource;
@property (strong, nonatomic) NSMutableSet *selectedMembers;

@end

#pragma mark GroupAddMembersViewController

@implementation GroupAddMembersViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (NSArray *)addressBookDataSource {
    if (!_addressBookDataSource) {
        APAddressBook *addressBook = [APAddressBook new];
        addressBook.fieldsMask = APContactFieldEmails | APContactFieldFirstName | APContactFieldLastName | APContactFieldThumbnail | APContactFieldCompositeName;
        addressBook.filterBlock = ^BOOL(APContact *contact) {
            return contact.emails.count > 0;
        };
        addressBook.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES]];
        [addressBook loadContacts:^(NSArray *contacts, NSError *error) {
            self.addressBookDataSource = contacts;
            self.dataSource = contacts;
            if (self.searchBar.text.length > 0) {
                [self searchBar:self.searchBar textDidChange:self.searchBar.text];
            }
            [self.tableView reloadData];
        }];
        _addressBookDataSource = @[];
    }
    
    return _addressBookDataSource;
}

- (NSArray *)facebookDataSource {
    if (!_facebookDataSource) {
        _facebookDataSource = @[];

        NSString *graphPath = @"me/taggable_friends?fields=name,picture.type(normal)";
        if ([FBSession activeSession].isOpen) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            [self getFBFriends:graphPath];
        } else {
            [FBSession openActiveSessionWithReadPermissions:FB_READ_PERMISSIONS allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                if (error) {
                    SPLogError(@"Facebook error %@, %@", error, [error userInfo]);
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
                    [alertView show];
                } else {
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                    [self getFBFriends:graphPath];
                }
            }];
        }
    }
    
    return _facebookDataSource;
}

- (NSArray *)footblDataSource {
    if (!_footblDataSource) {
        _footblDataSource = @[@{@"name" : @"Carlo Dapuzzo", @"username" : @"dapuzzo"},
                              @{@"name" : @"Fernando Saragoça", @"username" : @"fsaragoca"},
                              @{@"name" : @"Marcel Muller", @"username" : @"grigio"},
                              @{@"name" : @"Rafael Erthal", @"username" : @"erthal"}];
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
                _dataSource = self.footblDataSource;
                break;
            case 1:
                _dataSource = self.addressBookDataSource;
                break;
            default:
                _dataSource = self.facebookDataSource;
                break;
        }
    }
    
    return _dataSource;
}

#pragma mark - Instance Methods

- (IBAction)segmentedControlAction:(id)sender {
    self.dataSource = nil;
    if (self.searchBar.text.length > 0) {
        [self searchBar:self.searchBar textDidChange:self.searchBar.text];
    }
    [self.searchBar resignFirstResponder];
    [self.tableView reloadData];
}

- (void)getFBFriends:(NSString *)graphPath {
    FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        self.facebookDataSource = [[self.facebookDataSource arrayByAddingObjectsFromArray:result[@"data"]] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        self.dataSource = nil;
        [self.tableView reloadData];
        
        if (result[@"paging"][@"next"]) {
            NSString *nextPath = [@"me" stringByAppendingPathComponent:[result[@"paging"][@"next"] lastPathComponent]];
            [self getFBFriends:nextPath];
        } else {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    }];
}

- (void)configureCell:(GroupAddMemberTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [cell restoreFrames];
    
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            cell.usernameLabel.text = self.dataSource[indexPath.row][@"username"];
            cell.nameLabel.text = self.dataSource[indexPath.row][@"name"];
            [cell restoreProfileImagePlaceholder];
            break;
        case 1: {
            APContact *contact = self.dataSource[indexPath.row];
            cell.usernameLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
            cell.nameLabel.text = contact.emails.firstObject;
            if (contact.thumbnail) {
                cell.profileImageView.image = contact.thumbnail;
            } else {
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
    [Group createWithChampionship:self.championship name:self.groupName success:nil failure:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
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
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.selectedMembers removeObject:self.dataSource[indexPath.row]];
}

#pragma mark - UISearchBar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString *text = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0) {
        self.dataSource = nil;
    } else {
        switch (self.segmentedControl.selectedSegmentIndex) {
            case 0:
                self.dataSource = [self.footblDataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@ OR username CONTAINS[cd] %@", text, text]];
                break;
            case 1:
                self.dataSource = [self.addressBookDataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"firstName CONTAINS[cd] %@ OR lastName CONTAINS[cd] %@ OR compositeName CONTAINS[cd] %@", text, text, text]];
                break;
            case 2:
                self.dataSource = [self.facebookDataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", text]];
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
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Add members", @"");
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Create", @"") style:UIBarButtonItemStylePlain target:self action:@selector(createAction:)];
    
    self.selectedMembers = [NSMutableSet new];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = 66;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.allowsMultipleSelection = YES;
    [self.tableView registerClass:[GroupAddMemberTableViewCell class] forCellReuseIdentifier:@"GroupMemberCell"];
    [self.view addSubview:self.tableView];
    
    UISearchBar *headerView = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 93)];
    headerView.searchBarStyle = UISearchBarStyleMinimal;
    self.tableView.tableHeaderView = headerView;
    [[self tableView] setTableHeaderView:headerView];
    
    @try {
        [[[[headerView subviews] objectAtIndex:0] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    } @catch (NSException *exception) {
        [[headerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Footbl", @""), NSLocalizedString(@"Contacts", @""), NSLocalizedString(@"Facebook", @"")]];
    self.segmentedControl.frame = CGRectMake(15, 9, 290, 29);
    self.segmentedControl.tintColor = [FootblAppearance colorForView:FootblColorTabBarTint];
    self.segmentedControl.selectedSegmentIndex = 1;
    [self.segmentedControl addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    [headerView addSubview:self.segmentedControl];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 46, CGRectGetWidth(self.view.frame), 47)];
    self.searchBar.barTintColor = [UIColor whiteColor];
    self.searchBar.backgroundColor = [UIColor colorWithRed:0.84 green:0.87 blue:0.85 alpha:1];
    self.searchBar.clipsToBounds = YES;
    self.searchBar.placeholder = NSLocalizedString(@"Type a friend's name", @"");
    self.searchBar.delegate = self;
    self.searchBar.backgroundImage = [UIImage new];
    [headerView addSubview:self.searchBar];
    
    for (UITextField *textField in [self.searchBar.subviews.firstObject subviews]) {
        if ([textField isKindOfClass:[UITextField class]]) {
            textField.textColor = [UIColor colorWithRed:0.56 green:0.56 blue:0.58 alpha:1];
            textField.backgroundColor = [UIColor whiteColor];
        }
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
