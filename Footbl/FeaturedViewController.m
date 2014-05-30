//
//  FeaturedViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/23/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "FeaturedViewController.h"
#import "FootblAPI.h"
#import "User.h"

@interface FeaturedViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSDate *lastUpdateAt;

@end

#pragma mark FeaturedViewController

@implementation FeaturedViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

@synthesize fetchedResultsController = _fetchedResultsController;

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"rid" ascending:YES]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"featured = %@", @YES];
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

- (void)reloadData {
    self.lastUpdateAt = [NSDate date];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
    });
    
    [User updateFeaturedUsersWithSuccess:^{
        [self.refreshControl endRefreshing];
    } failure:^(NSError *error) {
        [self.refreshControl endRefreshing];
        [[ErrorHandler sharedInstance] displayError:error];
    }];
}

#pragma mark - Delegates & Data sources

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Featured users title", @"");
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
