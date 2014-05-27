//
//  FavoritesViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/23/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "FavoriteTableViewCell.h"
#import "FavoritesViewController.h"
#import "FeaturedViewController.h"
#import "FootblAPI.h"
#import "ProfileViewController.h"
#import "User.h"

@interface FavoritesViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

#pragma mark FavoritesViewController

@implementation FavoritesViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"rid" ascending:YES]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"ANY starredByUsers.rid = %@", self.user.rid];
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

- (IBAction)featuredAction:(id)sender {
    [self.navigationController pushViewController:[FeaturedViewController new] animated:YES];
}

- (void)configureCell:(FavoriteTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    User *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.nameLabel.text = user.name;
    cell.usernameLabel.text = user.username;
    cell.verified = user.verifiedValue;
    [cell.profileImageView setImageWithURL:[NSURL URLWithString:user.picture] placeholderImage:cell.placeholderImage];
}

- (void)reloadData {
    [super reloadData];
    
    [self.user updateStarredUsersWithSuccess:^{
        [self.refreshControl endRefreshing];
    } failure:^(NSError *error) {
        [self.refreshControl endRefreshing];
        [[ErrorHandler sharedInstance] displayError:error];
    }];
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
    FavoriteTableViewCell *cell = (FavoriteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FavoriteCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.user.isMe;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        User *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.user.editableObject unstarUser:user success:nil failure:nil];
    }
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileViewController *profileViewController = [ProfileViewController new];
    profileViewController.user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Favorites", @"");
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    
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
    self.tableView.rowHeight = 66;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.tableView registerClass:[FavoriteTableViewCell class] forCellReuseIdentifier:@"FavoriteCell"];
    [self.view addSubview:self.tableView];
    
    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kFootblAPINotificationAuthenticationChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self reloadData];
    }];

    if (self.shouldShowFeatured) {
        UIButton *featuredButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), self.tableView.rowHeight)];
        [featuredButton setImage:[UIImage imageNamed:@"featured_user"] forState:UIControlStateNormal];
        [featuredButton setTitle:NSLocalizedString(@"Featured users", @"") forState:UIControlStateNormal];
        [featuredButton setTitleColor:[UIColor ftGreenGrassColor] forState:UIControlStateNormal];
        [featuredButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        featuredButton.titleLabel.font = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:17];
        featuredButton.imageEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
        featuredButton.titleEdgeInsets = UIEdgeInsetsMake(0, 80 - featuredButton.imageView.image.size.width, 0, 0);
        [featuredButton addTarget:self action:@selector(featuredAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"goto"]];
        arrowImageView.center = CGPointMake(CGRectGetWidth(featuredButton.frame) - 20, CGRectGetMidY(featuredButton.frame));
        [featuredButton addSubview:arrowImageView];
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetHeight(featuredButton.frame) - 0.5, CGRectGetWidth(featuredButton.frame) - 15, 0.5)];
        separatorView.backgroundColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.83 alpha:1];
        separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [featuredButton addSubview:separatorView];
        
        self.tableView.tableHeaderView = featuredButton;
    }
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
