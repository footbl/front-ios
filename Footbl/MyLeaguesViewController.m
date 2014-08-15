//
//  MyLeaguesViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 8/15/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "Championship.h"
#import "Entry.h"
#import "GroupChampionshipTableViewCell.h"
#import "LoadingHelper.h"
#import "MyLeaguesViewController.h"
#import "User.h"

@interface MyLeaguesViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

#pragma mark MyLeaguesViewController

@implementation MyLeaguesViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Championship"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"rid" ascending:NO]];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[FTModel managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
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

- (void)reloadData {
    [super reloadData];
    
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        [[LoadingHelper sharedInstance] showHud];
    }
    
    [Championship getWithObject:nil success:^(id response) {
        [self.refreshControl endRefreshing];
        [[LoadingHelper sharedInstance] hideHud];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.refreshControl endRefreshing];
        [[LoadingHelper sharedInstance] hideHud];
        [[ErrorHandler sharedInstance] displayError:error];
    }];
}

- (void)configureCell:(GroupChampionshipTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Championship *championship = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.nameLabel.text = championship.displayName;
    cell.informationLabel.text = [NSString stringWithFormat:@"%@, %@", [championship.displayCountry stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], championship.edition.stringValue];
    [cell.championshipImageView setImageWithURL:[NSURL URLWithString:championship.picture] placeholderImage:[UIImage imageNamed:@"generic_group"]];
    if (championship.enabledValue) {
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
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
    GroupChampionshipTableViewCell *cell = (GroupChampionshipTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ChampionshipCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Championship *championship = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [Entry createWithParameters:@{kFTRequestParamResourcePathObject : [User currentUser], @"championship" : championship.slug} success:nil failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[ErrorHandler sharedInstance] displayError:error];
    }];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    Championship *championship = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [championship.entry deleteWithSuccess:nil failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[ErrorHandler sharedInstance] displayError:error];
    }];
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    self.title = NSLocalizedString(@"My Leagues", @"");
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    tableViewController.refreshControl = self.refreshControl;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kFTNotificationAuthenticationChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
    self.tableView = tableViewController.tableView;
    self.tableView.frame = self.view.bounds;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = 60;
    self.tableView.allowsMultipleSelection = YES;
    [self.tableView registerClass:[GroupChampionshipTableViewCell class] forCellReuseIdentifier:@"ChampionshipCell"];
    [self.view addSubview:self.tableView];
    
    [self reloadData];
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