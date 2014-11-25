//
//  GroupsViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "AnonymousViewController.h"
#import "Championship.h"
#import "Group.h"
#import "GroupDetailViewController.h"
#import "GroupsViewController.h"
#import "GroupTableViewCell.h"
#import "FootblNavigationController.h"
#import "FTAuthenticationManager.h"
#import "NewGroupViewController.h"
#import "NSString+Hex.h"
#import "User.h"

@interface GroupsViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) AnonymousViewController *anonymousViewController;

@end

#pragma mark GroupsViewController

@implementation GroupsViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"isDefault" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], [NSSortDescriptor sortDescriptorWithKey:@"rid" ascending:YES]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"removed = %@", @NO];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[FTCoreDataStore mainQueueContext] sectionNameKeyPath:@"isDefault" cacheName:nil];
        self.fetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![_fetchedResultsController performFetch:&error]) {
            SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return _fetchedResultsController;
}

#pragma mark - Instance Methods

- (IBAction)editAction:(id)sender {
    
}

- (IBAction)joinGroupAction:(id)sender {
    NewGroupViewController *newGroupViewController = [NewGroupViewController new];
    newGroupViewController.invitationMode = YES;
    [self presentViewController:[[FootblNavigationController alloc] initWithRootViewController:newGroupViewController] animated:YES completion:nil];
}

- (IBAction)newGroupAction:(id)sender {
    [self presentViewController:[[FootblNavigationController alloc] initWithRootViewController:[NewGroupViewController new]] animated:YES completion:nil];
}

- (id)init {
    if (self) {
        self.title = NSLocalizedString(@"Groups", @"");
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title image:[UIImage imageNamed:@"tabbar_btn_groups_inactive"] selectedImage:[UIImage imageNamed:@"tabbar_btn_groups_active"]];
    }
    
    return self;
}

- (void)configureCell:(GroupTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Group *group = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.nameLabel.text = group.name;
    if (group.isDefaultValue) {
        [cell.groupImageView setImage:[UIImage imageNamed:@"world_icon"]];
    } else {
        [cell.groupImageView sd_setImageWithURL:[NSURL URLWithString:group.picture] placeholderImage:[UIImage imageNamed:@"generic_group"]];
    }
    [cell setIndicatorHidden:(!group.isNewValue || group.isDefaultValue) animated:NO];
    [cell setUnreadCount:group.unreadMessagesCount];
    
    cell.bottomSeparatorView.hidden = (indexPath.section == 0 && [self numberOfSectionsInTableView:self.tableView] > 1 && indexPath.row + 1 == [self tableView:self.tableView numberOfRowsInSection:0]);
    cell.topSeparatorView.hidden = !(indexPath.section == 1 && [self numberOfSectionsInTableView:self.tableView] > 1 && indexPath.row == 0);
}

- (void)reloadData {
    [super reloadData];
    
    void(^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.refreshControl endRefreshing];
        [[ErrorHandler sharedInstance] displayError:error];
    };
    
    [Group getWithObject:nil success:^(id response) {
        [[User currentUser] getStarredWithSuccess:^(id response) {
            [self.refreshControl endRefreshing];
        } failure:failureBlock];
    } failure:failureBlock];
}

- (void)setFooterViewVisible:(BOOL)visible {
    if (visible) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), self.tableView.rowHeight)];
        footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIButton *button = [[UIButton alloc] initWithFrame:footerView.frame];
        button.backgroundColor = self.view.backgroundColor;
        [button setImage:[UIImage imageNamed:@"groups_createnewgroup"] forState:UIControlStateNormal];
        button.titleLabel.numberOfLines = 0;
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        NSMutableAttributedString *buttonTitle = [NSMutableAttributedString new];
        [buttonTitle appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Create your group button title", @"") attributes:@{NSFontAttributeName : [UIFont fontWithName:kFontNameAvenirNextDemiBold size:16], NSForegroundColorAttributeName : [UIColor colorWithRed:137/255.f green:148/255.f blue:140/255.f alpha:1.00]}]];
        [buttonTitle appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        [buttonTitle appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Create your group button subtitle", @"")attributes:@{NSFontAttributeName : [UIFont fontWithName:kFontNameMedium size:14], NSForegroundColorAttributeName : [UIColor colorWithRed:161/255.f green:170/255.f blue:163/255.f alpha:1.00]}]];
        
        [button setAttributedTitle:buttonTitle forState:UIControlStateNormal];
        
        if ([UIScreen mainScreen].bounds.size.width == 320) { // iPhone 3.5" & iPhone 4"
            button.imageEdgeInsets = UIEdgeInsetsMake(0, 24, 0, 0);
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 40, 0, 20);
        } else if ([UIScreen mainScreen].bounds.size.width == 414) { // iPhone 5.5"
            button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 48);
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 20);
        } else {
            button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 11);
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 40, 0, 20);
        }
        
        [button addTarget:self action:@selector(newGroupAction:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:button];
        self.tableView.tableFooterView = footerView;
    } else {
        self.tableView.tableFooterView = nil;
    }
}

#pragma mark - Delegates & Data sources

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupTableViewCell *cell = (GroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Group *group = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [group.editableObject deleteWithSuccess:nil failure:nil];
    }
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupDetailViewController *groupDetailViewController = [GroupDetailViewController new];
    groupDetailViewController.group = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:groupDetailViewController animated:YES];
}

#pragma mark - NSFetchedResultsController delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [super controllerDidChangeContent:controller];
    
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    
    if (FBTweakValue(@"UX", @"Group", @"Join button", YES)) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Join", @"") style:UIBarButtonItemStylePlain target:self action:@selector(joinGroupAction:)];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newGroupAction:)];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    tableViewController.refreshControl = self.refreshControl;
    
    self.tableView = tableViewController.tableView;
    self.tableView.frame = self.view.bounds;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 96;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.tableView registerClass:[GroupTableViewCell class] forCellReuseIdentifier:@"GroupCell"];
    [self.view addSubview:self.tableView];
    
    [self setFooterViewVisible:YES];
    
    self.anonymousViewController = [AnonymousViewController new];
    
    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kFTNotificationAuthenticationChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if ([FTAuthenticationManager sharedManager].isAuthenticated) {
            [self reloadData];
        }
        
        if ([FTAuthenticationManager sharedManager].authenticationType == FTAuthenticationTypeAnonymous) {
            [self addChildViewController:self.anonymousViewController];
            [self.view addSubview:self.anonymousViewController.view];
            self.navigationItem.rightBarButtonItem.enabled = NO;
        } else {
            [self.anonymousViewController.view removeFromSuperview];
            [self.anonymousViewController removeFromParentViewController];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (FBTweakValue(@"UX", @"Group", @"Join button", YES)) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Join", @"") style:UIBarButtonItemStylePlain target:self action:@selector(joinGroupAction:)];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    if (self.tableView.indexPathForSelectedRow) {
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
    
    if ([FTAuthenticationManager sharedManager].authenticationType == FTAuthenticationTypeAnonymous) {
        [self addChildViewController:self.anonymousViewController];
        [self.view addSubview:self.anonymousViewController.view];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        [self.anonymousViewController.view removeFromSuperview];
        [self.anonymousViewController removeFromParentViewController];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
