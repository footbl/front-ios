//
//  MyChallengesViewController.m
//  Footbl
//
//  Created by Leonardo Formaggio on 9/30/15.
//  Copyright © 2015 Footbl. All rights reserved.
//

#import "MyChallengesViewController.h"
#import "MyChallengeCell.h"

@interface MyChallengesViewController ()

@end

@implementation MyChallengesViewController

#pragma mark - Class Methods

+ (NSString *)storyboardName {
    return @"Main";
}

#pragma mark - Instance Methods

- (void)configureCell:(MyChallengeCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Lifecycle

- (void)commomInit {
    self.title = @"Challenges";
    
    UIImage *image = [UIImage imageNamed:@"tabbar-groups"];
    UIImage *selectedImage = [UIImage imageNamed:@"tabbar-groups-selected"];
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title image:image selectedImage:selectedImage];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commomInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commomInit];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	MyChallengeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

#pragma mark - UITableViewDelegate

@end
