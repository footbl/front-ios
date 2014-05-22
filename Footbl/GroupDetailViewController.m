//
//  GroupDetailViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/2/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIButton+WebCache.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "Championship.h"
#import "Group.h"
#import "GroupDetailViewController.h"
#import "GroupInfoViewController.h"
#import "GroupMembershipTableViewCell.h"
#import "Membership.h"
#import "NSString+Hex.h"
#import "User.h"

@interface GroupDetailViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

#pragma mark GroupDetailViewController

@implementation GroupDetailViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController && self.group) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Membership"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"hasRanking" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"ranking" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"user.name" ascending:YES]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"group = %@", self.group];
        fetchRequest.includesSubentities = YES;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:FootblManagedObjectContext() sectionNameKeyPath:nil cacheName:nil];
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

- (IBAction)groupInfoAction:(id)sender {
    GroupInfoViewController *groupInfoViewController = [GroupInfoViewController new];
    groupInfoViewController.group = self.group;
    [self.navigationController pushViewController:groupInfoViewController animated:YES];
}

- (void)reloadData {
    [super reloadData];
    
    self.navigationItem.title = self.group.name;
    [self.rightNavigationBarButton setImageWithURL:[NSURL URLWithString:self.group.picture] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"generic_group"]];
    [self.group.editableObject updateMembersWithSuccess:^{
        [self.refreshControl endRefreshing];
    } failure:^(NSError *error) {
        [self.refreshControl endRefreshing];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
        [alert show];
    }];
}

- (void)configureCell:(GroupMembershipTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Membership *membership = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (membership.hasRankingValue) {
        cell.rankingLabel.text = [@"#" stringByAppendingString:membership.ranking.stringValue];
    } else {
        cell.rankingLabel.text = [@"#" stringByAppendingString:@(indexPath.row + 1).stringValue];
    }
    
    cell.usernameLabel.text = membership.user.username;
    cell.nameLabel.text = membership.user.name;
    
    if (membership.funds) {
        cell.walletLabel.text = membership.funds.stringValue;
    } else {
        cell.walletLabel.text = @"";
    }
    
    [cell.profileImageView setImageWithURL:[NSURL URLWithString:membership.user.picture] placeholderImage:cell.placeholderImage];
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
    GroupMembershipTableViewCell *cell = (GroupMembershipTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    
    self.title = NSLocalizedString(@"Group", @"");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.title style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.rightNavigationBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
    self.rightNavigationBarButton.layer.cornerRadius = CGRectGetWidth(self.rightNavigationBarButton.frame) / 2;
    self.rightNavigationBarButton.clipsToBounds = YES;
    [self.rightNavigationBarButton addTarget:self action:@selector(groupInfoAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightNavigationBarButton];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        self.navigationItem.title = self.group.name;
        [self.rightNavigationBarButton setImageWithURL:[NSURL URLWithString:self.group.picture] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"generic_group"]];
    }];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    tableViewController.refreshControl = self.refreshControl;
    
    self.tableView = tableViewController.tableView;
    self.tableView.frame = self.view.bounds;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = 75;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.tableView registerClass:[GroupMembershipTableViewCell class] forCellReuseIdentifier:@"GroupCell"];
    [self.view addSubview:self.tableView];
    
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = self.group.name;
    [self.rightNavigationBarButton setImageWithURL:[NSURL URLWithString:self.group.picture] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"generic_group"]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.group.isNewValue) {
        self.group.editableObject.isNew = @NO;
        SaveManagedObjectContext(self.group.editableManagedObjectContext);
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
