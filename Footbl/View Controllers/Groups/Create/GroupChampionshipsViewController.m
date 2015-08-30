//
//  GroupChampionshipsViewController.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/3/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "GroupAddMembersViewController.h"
#import "GroupChampionshipsViewController.h"
#import "GroupChampionshipTableViewCell.h"

#import "FTBClient.h"
#import "FTBChampionship.h"
#import "FTBUser.h"

@interface GroupChampionshipsViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

#pragma mark GroupChampionshipsViewController

@implementation GroupChampionshipsViewController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

#pragma mark - Instance Methods

- (void)configureCell:(GroupChampionshipTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    FTBChampionship *championship = self.championships[indexPath.row];
    cell.nameLabel.text = championship.name;
    cell.informationLabel.text = [NSString stringWithFormat:@"%@, %@", [championship.country stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], championship.edition.stringValue];
    [cell.championshipImageView sd_setImageWithURL:championship.pictureURL placeholderImage:[UIImage imageNamed:@"generic_group"]];
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
