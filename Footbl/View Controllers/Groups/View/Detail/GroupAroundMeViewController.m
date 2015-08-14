//
//  GroupAroundMeViewController.m
//  Footbl
//
//  Created by Cesar Barscevicius on 11/24/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "GroupAroundMeViewController.h"
#import "Group.h"
#import "User.h"

@interface GroupAroundMeViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSDate *lastUpdateAt;

@end

#pragma mark GroupRankingViewController

@implementation GroupAroundMeViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Membership"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"ranking" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"user.funds" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"user.name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"group = %@ AND user != nil AND hasRanking = %@ AND isLocalRanking = %@", self.group, @YES, @YES];
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

- (void)setContext:(GroupDetailContext)context {
    [super setContext:context];
    
    if (context == GroupDetailContextAroundMe) {
        [self.tableView scrollToRowAtIndexPath:[self.fetchedResultsController indexPathForObject:self.group.myMembership] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}

#pragma mark - Instance Methods

- (void)reloadData {
    [super reloadData];
    
    [self.group getLocalRankingMembersWithSuccess:^(id response) {
        [self.refreshControl endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.refreshControl endRefreshing];
        [[ErrorHandler sharedInstance] displayError:error];
    }];
}

#pragma mark - Delegates & Data sources

#pragma mark - NSFetchedResultsController delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    BOOL shouldScroll = self.tableView.visibleCells.count == 0;
    [super controllerDidChangeContent:controller];
    if (shouldScroll) {
        [self.tableView scrollToRowAtIndexPath:[self.fetchedResultsController indexPathForObject:self.group.myMembership] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
