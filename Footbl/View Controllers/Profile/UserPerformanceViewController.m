//
//  UserPerformanceViewController.m
//  Footbl
//
//  Created by Leonardo Formaggio on 9/6/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "UserPerformanceViewController.h"
#import "UserPerformanceCell.h"

#define EVEN(A) ((A) % 2 == 0)

@interface UserPerformanceViewController ()

@end

@implementation UserPerformanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.evenColor = [UIColor lightGrayColor];
	self.oddColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private

- (void)configureCell:(UserPerformanceCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	cell.contentView.backgroundColor = EVEN(indexPath.row) ? self.evenColor : self.oddColor;
	cell.seasonLabel.text = nil;
	cell.walletLabel.text = nil;
	cell.xpLabel.text = nil;
	cell.levelLabel.text = nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UserPerformanceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

#pragma mark - UITableViewDelegate

@end
