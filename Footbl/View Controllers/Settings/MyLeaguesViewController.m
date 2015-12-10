//
//  MyLeaguesViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 8/15/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "GroupChampionshipTableViewCell.h"
#import "LoadingHelper.h"
#import "MyLeaguesViewController.h"

#import "FTBClient.h"
#import "FTBChampionship.h"
#import "FTBUser.h"

@interface MyLeaguesViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

#pragma mark MyLeaguesViewController

@implementation MyLeaguesViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (void)reloadData {
    [super reloadData];
    
    if (self.championships.count == 0) {
        [[LoadingHelper sharedInstance] showHud];
    }
	
	[[FTBClient client] championships:0 success:^(id object) {
		self.championships = object;
		[self.refreshControl endRefreshing];
		[[LoadingHelper sharedInstance] hideHud];
		[self.tableView reloadData];
	} failure:^(NSError *error) {
		[self.refreshControl endRefreshing];
		[[LoadingHelper sharedInstance] hideHud];
		[[ErrorHandler sharedInstance] displayError:error];
	}];
}

- (void)configureCell:(GroupChampionshipTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    FTBChampionship *championship = self.championships[indexPath.row];
    cell.nameLabel.text = championship.name;
	cell.informationLabel.text = championship.country;
	if (championship.edition.integerValue > 0) {
		cell.informationLabel.text = [championship.country stringByAppendingFormat:@", %@", championship.edition.stringValue];
	}
    [cell.championshipImageView sd_setImageWithURL:championship.pictureURL placeholderImage:[UIImage imageNamed:@"generic_group"]];
    if (championship.isEnabled) {
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - Delegates & Data sources

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.championships.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupChampionshipTableViewCell *cell = (GroupChampionshipTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ChampionshipCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	FTBUser *user = [FTBUser currentUser];
    FTBChampionship *championship = self.championships[indexPath.row];
	NSMutableArray *entries = [[NSMutableArray alloc] initWithArray:user.entries];
	[entries addObject:championship];
	[[FTBClient client] updateEntries:entries success:^(id object) {
		[self reloadData];
	} failure:^(NSError *error) {
		[[ErrorHandler sharedInstance] displayError:error];
	}];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	FTBUser *user = [FTBUser currentUser];
    FTBChampionship *championship = self.championships[indexPath.row];
	NSMutableArray *entries = [[NSMutableArray alloc] initWithArray:user.entries];
	[entries removeObject:championship];
	[[FTBClient client] updateEntries:entries success:^(id object) {
		[self reloadData];
	} failure:^(NSError *error) {
		[[ErrorHandler sharedInstance] displayError:error];
		[self reloadData];
	}];
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor ftb_viewMatchBackgroundColor];
    self.title = NSLocalizedString(@"My Leagues", @"");
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    tableViewController.refreshControl = self.refreshControl;
    
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
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kFTNotificationAuthenticationChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
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
