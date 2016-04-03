//
//  UserPerformanceViewController.m
//  Footbl
//
//  Created by Leonardo Formaggio on 9/6/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "UserPerformanceViewController.h"
#import "FootblAppearance.h"
#import "UserPerformanceCell.h"

#define EVEN(A) ((A) % 2 == 0)

@interface UserPerformanceViewController ()

@end

@implementation UserPerformanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.evenColor = [UIColor ftb_cellMatchBackgroundColor];
	self.oddColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private

- (void)configureCell:(UserPerformanceCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	cell.contentView.backgroundColor = EVEN(indexPath.row) ? self.evenColor : self.oddColor;
	cell.seasonLabel.text = @(indexPath.row + 1).stringValue;
	cell.walletLabel.text = @(100 * indexPath.row + 100).stringValue;
	cell.xpLabel.text = @(2*indexPath.row + 30).stringValue;
	cell.levelLabel.text = @(indexPath.row + 10).stringValue;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UserPerformanceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *view = [tableView headerViewForSection:section];
	if (!view) {
		view = tableView.tableHeaderView;
		tableView.tableHeaderView = nil;
	}
	return view;
}

@end
