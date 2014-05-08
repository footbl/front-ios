//
//  GroupsViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 4/1/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "Championship.h"
#import "Group.h"
#import "GroupDetailViewController.h"
#import "GroupsViewController.h"
#import "GroupTableViewCell.h"
#import "FootblNavigationController.h"
#import "NewGroupViewController.h"
#import "NSString+Hex.h"

@interface GroupsViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

#pragma mark GroupsViewController

@implementation GroupsViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"removed = %@", @NO];
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

- (IBAction)editAction:(id)sender {
    
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
    cell.championshipLabel.text = group.championship.name;
    [cell setIndicatorHidden:!group.isNewValue animated:NO];
    switch (group.championship.pendingRounds.integerValue) {
        case 0:
            cell.roundsLabel.text = NSLocalizedString(@"Championship finished", @"");
            break;
        case 1:
            cell.roundsLabel.text = NSLocalizedString(@"1 round to end", @"1 round to end");
            break;
        default:
            cell.roundsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%i rounds to end", @"{number of rounds} rounds to end"), group.championship.pendingRounds.integerValue];
            break;
    }
    
    // Just for testing
    [cell.groupImageView setImageWithURL:[NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/6954324/Aplicativos/Footbl/Temp/Fifa%20World%20Cup%20Logo.png"]];
}

- (void)reloadData {
    [Group updateWithSuccess:^{
        [self.refreshControl endRefreshing];
    } failure:^(NSError *error) {
        [self.refreshControl endRefreshing];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
        [alert show];
    }];
}

- (void)setFooterViewVisible:(BOOL)visible {
    if (visible) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), self.tableView.rowHeight)];
        UIButton *button = [[UIButton alloc] initWithFrame:footerView.frame];
        button.backgroundColor = self.view.backgroundColor;
        [button setImage:[UIImage imageNamed:@"groups_createnewgroup"] forState:UIControlStateNormal];
        button.titleLabel.numberOfLines = 0;
        
        NSMutableAttributedString *buttonTitle = [NSMutableAttributedString new];
        [buttonTitle appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Create your group button title", @"") attributes:@{NSFontAttributeName : [UIFont fontWithName:kFontNameAvenirNextDemiBold size:16], NSForegroundColorAttributeName : [UIColor colorWithRed:137/255.f green:148/255.f blue:140/255.f alpha:1.00]}]];
        [buttonTitle appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        [buttonTitle appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Create your group button subtitle", @"")attributes:@{NSFontAttributeName : [UIFont fontWithName:kFontNameMedium size:14], NSForegroundColorAttributeName : [UIColor colorWithRed:161/255.f green:170/255.f blue:163/255.f alpha:1.00]}]];
        
        [button setAttributedTitle:buttonTitle forState:UIControlStateNormal];
        
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 24, 0, 0);
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 40, 0, 20);
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

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
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
    
    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kFootblAPINotificationAuthenticationChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self reloadData];
    }];
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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
