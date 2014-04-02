//
//  MatchesViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/27/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "Championship.h"
#import "FootblTabBarController.h"
#import "Match.h"
#import "MatchTableViewCell.h"
#import "MatchesViewController.h"
#import "Team.h"
#import "TeamsViewController.h"

static CGFloat kScrollMinimumVelocityToToggleTabBar = 200.f;

@interface MatchesViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (assign, nonatomic) CGPoint tableViewOffset;

@end

#pragma mark MatchesViewController

@implementation MatchesViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Match"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"championship = %@", self.championship];
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

- (void)setChampionship:(Championship *)championship {
    _championship = championship;
    self.fetchedResultsController = nil;
    [self.tableView reloadData];
}

#pragma mark - Instance Methods

- (id)init {
    if (self) {
        self.title = NSLocalizedString(@"Matches", @"");
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title image:[UIImage new] tag:0];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Championship"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        fetchRequest.fetchLimit = 1;
        NSError *error = nil;
        NSArray *fetchResult = [FootblManagedObjectContext() executeFetchRequest:fetchRequest error:&error];
        if (error) {
            SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        if (fetchResult.count > 0) {
            self.championship = fetchResult.firstObject;
        }
    }
    
    return self;
}

- (void)configureCell:(MatchTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Match *match = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ x %@ %@", match.host.name, match.hostScore, match.guestScore, match.guest.name];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@ - %@", match.potHost, match.potDraw, match.potGuest];
}

- (void)reloadData {
    void(^failure)(NSError *error) = ^(NSError *error) {
        [self.refreshControl endRefreshing];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
        [alert show];
    };
    
    [Championship updateWithSuccess:^{
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Championship"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        fetchRequest.fetchLimit = 1;
        NSError *error = nil;
        NSArray *fetchResult = [FootblManagedObjectContext() executeFetchRequest:fetchRequest error:&error];
        if (error) {
            SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        self.championship = fetchResult.firstObject;
        
        [Match updateFromChampionship:self.championship.editableObject success:^{
            [Match updateBetsWithSuccess:^{
                [self.refreshControl endRefreshing];
            } failure:nil];
        } failure:failure];
    } failure:failure];
}

#pragma mark - Delegates & Data sources

#pragma mark - UIScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.tableViewOffset = scrollView.contentOffset;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    FootblTabBarController *tabBarController = (FootblTabBarController *)self.tabBarController;
    
    CGFloat tabBarHeight = CGRectGetHeight(tabBarController.tabBar.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    CGFloat velocityY = [scrollView.panGestureRecognizer velocityInView:self.view].y;
    CGFloat tabBarInsetTop = 20.f;
    
    BOOL isContentBehindTabBar = scrollView.contentSize.height - scrollView.contentOffset.y < viewHeight + tabBarInsetTop + tabBarHeight * 3;
    if (viewHeight < scrollView.contentSize.height && (velocityY < -kScrollMinimumVelocityToToggleTabBar || isContentBehindTabBar)) {
        [tabBarController setTabBarHidden:YES animated:YES];
    } else if (viewHeight > scrollView.contentSize.height || (velocityY > kScrollMinimumVelocityToToggleTabBar && !isContentBehindTabBar)) {
        [tabBarController setTabBarHidden:NO animated:YES];
    }
}

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MatchTableViewCell *cell = (MatchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MatchCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    tableViewController.refreshControl = self.refreshControl;
    
    CGRect tableViewFrame = self.tabBarController.view.frame;
    tableViewFrame.size.height -= CGRectGetHeight(self.navigationController.navigationBar.frame) + CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    
    self.tableView = tableViewController.tableView;
    self.tableView.frame = tableViewFrame;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 60;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.tableView registerClass:[MatchTableViewCell class] forCellReuseIdentifier:@"MatchCell"];
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
