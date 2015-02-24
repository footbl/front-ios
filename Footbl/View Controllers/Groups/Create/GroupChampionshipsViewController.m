//
//  GroupChampionshipsViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/3/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "Championship.h"
#import "GroupAddMembersViewController.h"
#import "GroupChampionshipsViewController.h"
#import "GroupChampionshipTableViewCell.h"
#import "User.h"

@interface GroupChampionshipsViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

#pragma mark GroupChampionshipsViewController

@implementation GroupChampionshipsViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Championship"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"ANY wallets.user.rid = %@ AND ANY wallets.active = %@", [User currentUser].rid, @YES];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[FTCoreDataStore mainQueueContext] sectionNameKeyPath:nil cacheName:nil];
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

- (void)configureCell:(GroupChampionshipTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Championship *championship = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.nameLabel.text = championship.displayName;
    cell.informationLabel.text = [NSString stringWithFormat:@"%@, %@", [championship.displayCountry stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], championship.edition.stringValue];
    [cell.championshipImageView sd_setImageWithURL:[NSURL URLWithString:championship.picture] placeholderImage:[UIImage imageNamed:@"generic_group"]];
}

- (void)reloadData {
    [super reloadData];
    
    /*
    [Wallet updateWithUser:[User currentUser] success:^{
        [self.refreshControl endRefreshing];
    } failure:^(NSError *error) {
        [self.refreshControl endRefreshing];
        [[ErrorHandler sharedInstance] displayError:error];
    }];
    */
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
    GroupChampionshipTableViewCell *cell = (GroupChampionshipTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ChampionshipCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        GroupAddMembersViewController *addMembersViewController = [GroupAddMembersViewController new];
        addMembersViewController.groupName = self.groupName;
        addMembersViewController.groupImage = self.groupImage;
        [self.navigationController pushViewController:addMembersViewController animated:YES];
        tableView.userInteractionEnabled = YES;
    });
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Select league", @"");
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
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
    self.tableView.rowHeight = 60;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.tableView registerClass:[GroupChampionshipTableViewCell class] forCellReuseIdentifier:@"ChampionshipCell"];
    [self.view addSubview:self.tableView];
    
    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kFTNotificationAuthenticationChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end