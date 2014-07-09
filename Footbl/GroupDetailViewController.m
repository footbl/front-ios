//
//  GroupDetailViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/2/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIButton+WebCache.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVPullToRefresh/SVPullToRefresh.h>
#import "Championship.h"
#import "FootblNavigationController.h"
#import "Group.h"
#import "GroupDetailViewController.h"
#import "GroupInfoViewController.h"
#import "GroupMembershipTableViewCell.h"
#import "LoadingHelper.h"
#import "Membership.h"
#import "NSNumber+Formatter.h"
#import "NSString+Hex.h"
#import "ProfileViewController.h"
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
        if (self.group.isDefaultValue) {
            fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"ranking" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"funds" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"user.name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"group = %@ AND user != nil AND hasRanking = %@", self.group, @YES];
        } else {
            fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"hasRanking" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"ranking" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"funds" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"user.name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"group = %@ AND user != nil", self.group];
        }
        
        fetchRequest.includesSubentities = YES;
        if (!self.tableView.infiniteScrollingView) {
            fetchRequest.fetchLimit = 20;
        }
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:FootblManagedObjectContext() sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
        
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

- (NSTimeInterval)updateInterval {
    return 60 * 60 * 24 * 365;
}

- (void)reloadData {
    [super reloadData];
    
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        [[LoadingHelper sharedInstance] showHud];
    }
    
    self.navigationItem.title = self.group.name;
    [self.rightNavigationBarButton setImageWithURL:[NSURL URLWithString:self.group.picture] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"generic_group"]];
    [self.group cancelMembersUpdate];
    [self.group.editableObject updateMembersWithSuccess:^(NSNumber *shouldContinue) {
        [self setupInfiniteScrolling];
        self.tableView.showsInfiniteScrolling = shouldContinue.boolValue;
        [self.refreshControl endRefreshing];
        [[LoadingHelper sharedInstance] hideHud];
    } failure:^(NSError *error) {
        [self.refreshControl endRefreshing];
        [[LoadingHelper sharedInstance] hideHud];
        [[ErrorHandler sharedInstance] displayError:error];
    }];
}

- (void)setupInfiniteScrolling {
    if (self.tableView.infiniteScrollingView) {
        return;
    }
    
    __weak typeof(self.tableView)weakTableView = self.tableView;
    [weakTableView addInfiniteScrollingWithActionHandler:^{
        [super reloadData];
        
        if (self.fetchedResultsController.fetchedObjects.count == 0) {
            [[LoadingHelper sharedInstance] showHud];
        }
        
        self.navigationItem.title = self.group.name;
        [self.rightNavigationBarButton setImageWithURL:[NSURL URLWithString:self.group.picture] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"generic_group"]];
        [self.group.editableObject updateMembersWithSuccess:^(NSNumber *shouldContinue) {
            [weakTableView.infiniteScrollingView stopAnimating];
            if (!shouldContinue.boolValue) {
                self.tableView.showsInfiniteScrolling = shouldContinue.boolValue;
            }
            [[LoadingHelper sharedInstance] hideHud];
        } failure:^(NSError *error) {
            [weakTableView.infiniteScrollingView stopAnimating];
            [[LoadingHelper sharedInstance] hideHud];
            [[ErrorHandler sharedInstance] displayError:error];
        }];
    }];
}

- (void)configureCell:(GroupMembershipTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Membership *membership = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (membership.hasRankingValue) {
        cell.rankingLabel.text = membership.ranking.rankingStringValue;
    } else {
        cell.rankingLabel.text = @(indexPath.row + 1).rankingStringValue;
    }
    
    cell.usernameLabel.text = membership.user.username;
    cell.nameLabel.text = membership.user.name;
    
    if ([membership.lastRounds count] > 1 && membership.lastRounds[1][@"ranking"]) {
        cell.rankingProgress = @([membership.lastRounds[1][@"ranking"] integerValue] - membership.rankingValue);
    } else {
        cell.rankingProgress = @(0);
    }
    
    if (membership.funds) {
        cell.walletLabel.text = membership.funds.shortStringValue;
    } else {
        cell.walletLabel.text = @"";
    }
    
    [cell.profileImageView setImageWithURL:[NSURL URLWithString:membership.user.picture] placeholderImage:cell.placeholderImage];
}

- (void)setupTitleView {
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSMutableDictionary *titleAttributes = [[[UINavigationBar appearanceWhenContainedIn:[FootblNavigationController class], nil] titleTextAttributes] mutableCopy];
    titleAttributes[NSParagraphStyleAttributeName] = paragraphStyle;
    NSMutableDictionary *highlightedAttributes = [titleAttributes mutableCopy];
    highlightedAttributes[NSForegroundColorAttributeName] = [highlightedAttributes[NSForegroundColorAttributeName] colorWithAlphaComponent:0.2];
    NSMutableDictionary *subAttributes = [titleAttributes mutableCopy];
    subAttributes[NSForegroundColorAttributeName] = [UIColor lightGrayColor];
    subAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:11];
    NSMutableDictionary *highlightedSubAttributes = [subAttributes mutableCopy];
    highlightedSubAttributes[NSForegroundColorAttributeName] = [highlightedSubAttributes[NSForegroundColorAttributeName] colorWithAlphaComponent:0.2];
    
    UIButton *titleViewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleViewButton.titleLabel.numberOfLines = 2;
    
    NSString *groupName = self.group.championship.displayName;
    if (self.group.isDefaultValue) {
        groupName = self.group.championship.displayCountry;
    }
    
    NSMutableAttributedString *buttonText = [NSMutableAttributedString new];
    [buttonText appendAttributedString:[[NSAttributedString alloc] initWithString:self.title attributes:titleAttributes]];
    [buttonText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:titleAttributes]];
    [buttonText appendAttributedString:[[NSAttributedString alloc] initWithString:groupName attributes:subAttributes]];
    
    NSMutableAttributedString *highlightedButtonText = [NSMutableAttributedString new];
    [highlightedButtonText appendAttributedString:[[NSAttributedString alloc] initWithString:self.title attributes:highlightedAttributes]];
    [highlightedButtonText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:highlightedAttributes]];
    [highlightedButtonText appendAttributedString:[[NSAttributedString alloc] initWithString:groupName attributes:highlightedSubAttributes]];
    
    [titleViewButton setAttributedTitle:buttonText forState:UIControlStateNormal];
    [titleViewButton setAttributedTitle:highlightedButtonText forState:UIControlStateHighlighted];
    [titleViewButton addTarget:self action:@selector(groupInfoAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleViewButton;
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

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Membership *membership = [self.fetchedResultsController objectAtIndexPath:indexPath];
    ProfileViewController *profileViewController = [ProfileViewController new];
    profileViewController.user = membership.user;
    [self.navigationController pushViewController:profileViewController animated:YES];
}

#pragma mark - NSFetchedResultsController delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [super controllerDidChangeContent:controller];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.fetchedResultsController = nil;
        [self.tableView reloadData];
    });
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    
    self.title = self.group.name;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.title style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self setupTitleView];
    
    self.rightNavigationBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 38, 38)];
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
    
    if (self.tableView.indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
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
